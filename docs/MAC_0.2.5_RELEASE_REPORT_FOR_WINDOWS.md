# Mac LTP 0.2.5: improvements and differences shipped (report for the Windows agent)

1 October 2026. Mac release **v0.2.5** is live on GitHub and is the latest release:
- notarized `LTP-0.2.5.dmg`, SHA-256 a28dcec18a65e829…;
- `latest.json`, so users on 0.2.2–0.2.4 are offered the update;
- Linux `ltp-0.2.5-linux-x86_64.tar.gz`;
- **`LTP-0.2.5-mac-source.zip`** (complete source);
- **`MAC_0.2.5_vs_WINDOWS_now.patch`** (diff against your tree as of 1 Oct ~01:25).

Verification: 338 tests passed from source and in the signed bundle; the signed app launches; an update 0.2.4 → 0.2.5 from GitHub was verified end to end.

Supporting reports are in `releases/methods_assessment_real_data/`:
- `LTP_illumination_comparison.html`
- `LTP_snr_deep_dive.html`
- `LTP_destripe_findings.html`
- `LTP_preprocessing_assessment.html`

**Please build Windows/Linux 0.2.5 from the Mac source zip**, keeping your Windows-only packaging, so both platforms run the same code.

---

## 1. Fix your engine needs: noise is estimated on the wrong data

- **Bug.** `illumination_cuda.statistics()` estimates noise on the averaged XY guide (about 17 µm pixels, each voxel averaging about 1,000–2,000 native pixels), which gives about 1 ADU (the floor). Real native noise is 9–40 ADU. The soft noise subtraction in `corrected()` therefore barely acts at native resolution, and `noise_sigma` 2 → 4 changes nothing.
- **Noise model** (real DRG, Blaze 12×, native crops). Poisson–Gaussian:
  - about 2.5 ADU per photo-electron;
  - offset about 105 ADU (empty space);
  - read noise about 4 ADU;
  - white noise.
  
  Deep tissue has about 14 e⁻ per pixel before a 24–37× gain.
- **Shipped on the Mac** (`illumination_route.py`):
  - **native noise model:** fit var = a·x + c on 8 evenly spaced native planes. On real native blocks it gave a = 2.47 / 2.43, R² 0.99. Guide statistics are used only to fit the field.
  - **`fast_gain` noise reduction (default):** Gaussian 0.5 µm XY everywhere, blended toward 1.0 µm XY / 1.5 µm Z where the gain is high. It is applied to the signal **before** the gain, in the apply step. It needs at least a 6 px XY halo and a ±1-plane Z buffer when applied in blocks.

  | Tissue | Display noise | Soma-blob CNR | 1.5–5 µm kept | 5–16 µm kept |
  |---|---|---|---|---|
  | Deep | ↓ 6.9× | 2.0 → 13.5 | 0.72 | 0.94 |
  | Mid | ↓ 5.2× | 10.5 → 49 | 0.88 | 0.98 |
  | Surface | ↓ 3.4× | — | 0.95 | 1.00 |

  Speed: 6 ms per 16.8 M voxels. It is linear, so it cannot invent structure.
  - **"Quality" option (Advanced):** generalised Anscombe VST → Perona–Malik (K 1.5, 20 iterations) → inverse, with raw values clamped at the offset first (otherwise dark specks appear). It is better on 1.5–5 µm structure in mid and surface tissue, and about 20× slower.
  - **"Off"** reproduces the previous output exactly.
- **What did not help:** gain caps (gain_max 12), gain_power 0.8, curve_toe 0.08, noise_sigma 4. They dim noisy regions but cost evenness without improving SNR. Mantiuk after illumination raises noise unless the noise reduction runs first.

## 2. Your illumination pipeline: validated, ported, and shipped as the recommended method

- **Real-data result** (tile + whole DRG at 740/645 nm). **Your 21 September pipeline is the best method:**
  - tissue evenness (p90/p10) 11–31 → 3.2–7.8;
  - deep tissue 10–50× brighter.
  
  It beat the Mac's simple gain field (11–34, brighten-only) and Mantiuk strong (3.6–4.3, but deep tissue only 3–4× brighter). Pipeline → mild Mantiuk (compression 0.5) gives the best evenness (2.3–4.0) but looks greyer.
- **Port:** `illumination_torch.py` is a PyTorch port (MPS and CUDA) with the same API, parameters and diagnostics.
  - Against your unmodified source run on NumPy/SciPy: ≤ 1e-6, same iterations.
  - Against your RTX outputs: correlation ≥ 0.9999999.

  | | Time per whole-DRG channel |
  |---|---|
  | Mac M5 Pro | 2.3 s |
  | RTX, your CuPy code | 1.1 s |
  | RTX, torch port | 0.7 s |

  Your source is kept verbatim as `tests/data/illumination_cuda_reference.py`, with an origin/SHA header, as the reference test.
- **Important:** the pipeline **does not converge when fitted on native 0.54 µm data** at default parameters ("did not converge: residual 0.00112"). The 45 µm regularisation stalls float32 CG, identically in your CuPy code and the port. The shipped route therefore:
  1. fits on an XY block-mean guide with full Z (≈ 17.3 µm XY, within 35 % of free GPU memory, your rule);
  2. applies the cached fields at output/native resolution in Z slabs (your FieldApplier design: field values at guide-block centres mapped to native coordinates).
- **Methods shipped** (`field_analysis.METHOD_REGISTRY`, all 8 in Advanced):
  - `illumination` ("Even out illumination") and `illumination_mantiuk` ("→ mild Mantiuk");
  - `multiscale_strong` (Mantiuk automatic strong) and `multiscale` (Mantiuk default);
  - `gainfield` ("Even out illumination (simple)", the older Mac method, Advanced only);
  - `asinh` and `percentile`.

## 3. Automatic method choice: rule changed

- **Problem.** On real tissue your bright-tail rule plus the Mac pattern rule picked **Mantiuk default**, the weakest option: the analysis found no clean geometric fall-off pattern, despite a 12–41× brightness range.
- **Shipped rule.** Broad brightness range ≥ 4× → illumination, illumination_mantiuk, multiscale_strong, then asinh/percentile, then Mantiuk default. Below 4×, your HDR rule is unchanged. The reason text reads "Tissue brightness varies N× across the volume → Even out illumination".
- **Mantiuk defaults are too gentle on real data.** Automatic strong is compression 0.15, detail = smallest physical extent ÷ 40 (5–100 µm), noise protection 0.5.

## 4. Mantiuk solver on Apple GPUs (`tonemap_mps.py`)

- A PyTorch port of `tonemap_cuda.py`, now optimised:
  - dense-matmul Gaussian filters with SciPy `reflect` edges;
  - dense DCT matrices;
  - both CG dots in one host transfer;
  - cached kernels.
- Speed: about 5–6× faster than before. Mac 1.1–10 s vs RTX (CuPy) 0.8–6.5 s for 17–52 M voxels. Peak memory 7.1 → 4.3 GiB at 52 M voxels.
- Agreement with real CUDA outputs:
  - **default settings:** same iterations, correlation ≥ 0.99999995;
  - **strong settings:** float32 tolerance-edge effects (iterations ±1–2, max |Δ| ≤ 1e-3; your float32 CuPy differs from float64 by the same amount).
- Your communication note saying "no native Apple MPS equivalent" is out of date. The Mac runs preprocessing locally, with SSH CUDA as the alternative.

## 5. De-striping (`destripe.py`): experimental, Advanced pre-step, off by default

- **What the stripes are.** Real stripes run along **X (0°)**, about 1–2 % intensity, 6–50 µm wide, often not field-spanning. There are weaker bands at about ±10° (angled sheets). Nerve fibres form broad orientation lobes near Y. A first Mac attempt failed by confusing Fourier and image orientation, which removed fibres.
- **Method.** `analyse_stripes` (directional scan + Fourier ring spectrum, slice-consistency, fibre-lobe rejection), then `destripe(method='auto')`: local rotated long-average, high-pass across stripes, gated against control angles. W 81 px, L 601 px.
- **Results:**
  - real data: 0° energy reduced 20–32 %, fibre response 0.998–0.9995;
  - synthetic: −40 to −55 % error on strong stripes, about nothing on weak (< 5 %) stripes, +0.47 % error when forced on stripe-free data;
  - **limitation:** it partly flattens surfaces running parallel to the stripes.
- **Integration.** `preprocess.PRESTEPS['destripe']` runs before the method (option `presteps: ['destripe']`, optional `destripe_angles`). Recommended order: raw → de-stripe → illumination → (Mantiuk).

## 6. Merged from you (kept as you wrote it unless noted)

- **OIR reader** (`_oirfile.py` + `olympus_oir.py`, BSD notice kept). Verified on the real `DRG- CD31 and Cldn5.oir`: 4×71×1024×1024, 3.93 / 1.243 / 1.243 µm, CH1 / DAPI … CH4 / Cy5.
- **Calibrated views** and µm scale bar, plus fluorophore names.
- **Other merges:**
  - `preprocess_compare.py`;
  - SSH profiles and remote file picker;
  - OME companions;
  - page-wise TIFF sampling;
  - h5py IMS metadata;
  - guided preprocessing (quick test → Accept / Try another).
- **Mac-specific decisions:**
  - **Setup layout (owner's decision):** preprocessing is a **folded "✨ Preprocess images (optional)" section inside Setup** after "2 · Source images". Your prominent button above Setup was not merged; please match this on Windows.
  - **One "Run on" selector:** This Mac / Workstation / SSH aliases. Your Windows CuPy local overlay (`local_preprocess.py` / `run_local`) was not merged on the Mac (Windows-only).
  - **Automatic sampling** for Mantiuk: 60 % of free GPU memory (Mac rule) instead of your 45 % CUDA-only rule.
  - **Name clash:** your draft `illumination.py` / `illumination_io.py` were not merged, because the Mac `illumination.py` is the simple gain field. Please adopt `illumination_torch.py` + `illumination_route.py` (they also run on torch CUDA) or rename your drafts.
  - **Fix beyond your code:** crops saved before units were recorded keep their spacing as µm. Your calibration change reset them to pixels, which broke volume calculations (auto-label minimum volume).

## 7. Asks for Windows

1. **Engine fixes (sections 1 and 2):**
   - estimate noise on native planes;
   - add `fast_gain` (default) and VST + Perona–Malik (Quality);
   - fit on the guide and apply at native resolution.
   
   Or adopt `illumination_route.py` directly.
2. **Automatic rule (section 3):** use the new broad-range rule and the automatic strong Mantiuk settings.
3. **Setup layout:** use the folded Preprocess section in Setup, not a button above it.
4. **Build:** build Windows/Linux 0.2.5 from `LTP-0.2.5-mac-source.zip`, run the suite on CUDA, and publish as a pre-release (the Mac `latest.json` stays the update feed).
5. **Real-data check:** run the four methods (illumination ± Mantiuk, Mantiuk strong, de-stripe pre-step) on your volumes and add the results to `releases/methods_assessment_real_data/`.

Not yet verified on the Mac:
- the workstation (torch-CUDA) illumination route on a real worker;
- native macOS rendering and point/shape alignment checked by eye in the full app.
