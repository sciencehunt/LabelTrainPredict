# Windows integration notes

30 September 2026, from the Mac agent. Target repository: sciencehunt/LabelTrainPredict.

This pre-release carries the **complete Mac 0.2.5 source** (`LTP-0.2.5-mac-source.zip`) and a unified diff against your Windows 0.2.4 network-options source (`MAC_0.2.5_vs_WINDOWS_0.2.4.patch`, 27 files). Please bring the Windows build to this source so both platforms are the same code again. It is a **pre-release**: the Mac updater follows only full releases, and `latest.json` is untouched. Please don't mark it latest.

State of this snapshot: full suite **202 tests OK, 5 skipped** on Apple silicon (MPS, `PYTORCH_ENABLE_MPS_FALLBACK=0`). It was not yet built, signed or released as a Mac app; that follows after the Inference stage below.

## What the Mac source adds on top of Windows 0.2.4

### 1. Your 0.2.4 network options run on Apple GPUs (no CUDA requirement)

- **Where the options are:** SE/K3 backbones, SE attention on/off, custom width/depth, flow/embedding/offset heads with weights, `cuda_basin_v1` decoder, block linking and read-only checkpoint structure. All merged unchanged in behaviour.
- **GPU guards:** every CUDA-only guard now accepts **CUDA or MPS** through `accel.py` (`accelerator()`, `require_gpu()`, `is_gpu_device()`, `autocast_enabled(device)`). There is still **no silent CPU fallback**.
- **MPS-portable helpers** (on CUDA they call the native op; on MPS they use an exact replacement):
  - `max_filter3d`, exact (also works around a PyTorch 2.6 MPS bug: constant `F.pad` along Z only returns wrong values for large volumes);
  - `max_pool3d`, `interpolate_trilinear`;
  - `scatter_amin_` / `scatter_amax_` (int64 via int32 on MPS);
  - `sample_trilinear_border`, `pdist`, `count_dtype`, `to_device_int64`.
  - GPU paths no longer create uint16/uint32/float64 tensors.
- **Validation, MPS vs CPU reference:**
  - SE/K3 × SE off/on × custom 12/3 × all heads: forward ≤5e-6, relative gradients ≤8.3e-7;
  - distance/boundary/offset targets identical; flow ≤6.2e-6 (except each object's undefined peak voxel);
  - basin decoder: identical labels on volumes up to 32×256×256;
  - block linking: identical;
  - end-to-end training with heads then a full-image TIFF: identical labels.
- **Decoder ID:** stays `cuda_basin_v1` for checkpoint compatibility. User text says "GPU (CUDA or Apple GPU)".
- **Please keep `accel.py`** and use its helpers in any new GPU code, instead of CUDA-only calls or `device.type != "cuda"` checks.

### 2. Mac platform code that your tree does not have (keep it; it is platform-conditional)

| Area | Mac code |
|---|---|
| nnInteractive | `nni_worker.py`: CUDA → MPS → CPU. `nninteractive_client.py`: macOS one-click setup, `CHECK_IMPORTS`, `explain()`, `repair_link()`. `nni_panel.py`: `offer_setup`, `repair_link` before start. |
| Folders | `diagnostics.py`: `~/Library/Logs/LabelWorkflow`. `presentation.py`: `~/Library/Application Support` on darwin. |
| Train on a workstation | `datasets.py` (`register_ssh_options`, StrictHostKeyChecking), `remote.py` (workdir/device from workstation), `remote_panel.py`, `remote_ssh.py`, and the Setup "4 · Where to train" section in widget.py. |
| Updater | `updater.py`, `update_panel.py`. |
| Inference margins | the `plan_blocks` receptive-field margins. For instance models only, the Mac trims them (never below max(32, patch/4)) when the margin alone would exceed the 2M-voxel decoder block. |

### 3. Behaviour changes to port to Windows as well

- **nnInteractive channels (owner's rule).** Use exactly the channels ticked for training; if none are ticked, use all. Never guess a nuclear stain.
  - The nnInteractive network takes one image channel, so several ticked channels are combined: each is scaled to its own 1-99.8 % range, then a voxel-wise maximum is taken.
  - The channel set re-syncs before a new object (never mid-object). The status line lists the channels.
  - Code: `nni_panel._channels/_volume/_describe/_sync_channel`.
- **Channel names for old crops.** `WorkflowWidget.with_channel_names(meta)` fills empty `channel_names` from the crop's source image (display only; `project.config['channels']` is unchanged). Crops cut by older versions from .oib showed "Channel 0/1/2".
- **Update notice.**
  - At every start: if newer, a separate popup :  "A new version of LTP is available", what's new, **Update now / Later**.
  - Then every 3 h while open: button only.
  - Never while a computation runs.
  - On Windows/Linux the action is "Open download page" (release page). Please make sure the Windows build shows this popup; the release notes in `latest.json` feed the "What's new" list.
- **Inference speed (all platforms).**
  - 2.5D previously copied whole planes (all channels × context) for every tile, and 3D/training copied whole crops per tile/sample (`image[c.channels]`). All extraction is now window-first; `context_patch()` is new.
  - 2.5D predicts with 256-px tiles (`_inference_tile_2d`) and batches 8 tiles per forward pass on GPUs (`LABEL_WORKFLOW_PREDICT_BATCH`). On out-of-memory it halves the batch first.
  - Measured on Apple silicon: 2.5D 16×1024×1024 went from 38.9 s to 2.8 s. 3D output is bit-identical, at the same speed.
  - Please measure on the RTX 6000 as well.
- **Naming.** User-visible "LTP" everywhere. Internal names are unchanged (package, `%LOCALAPPDATA%\LabelWorkflow`).

## Coming next on the Mac (not in this snapshot)

- **Inference stage** (owner request): Stage 3 "Inference" after Round 2.
  - Run any 2.5D/3D model on whole images.
  - A results list; open results in the viewer.
  - Pick or suggest difficult areas and add them as full-resolution crops that open with a suggestion; "Fix these in Round 2 →".
  - This will follow as a second source drop.
- **Defaults confirmed by the owner:** auxiliary heads **on** for 3D instance models (they only apply there), off otherwise.

## Ask

1. Merge this source into the Windows tree. Keep your Windows-only packaging and anything Windows-specific.
2. Run the full suite on CUDA, including the converted `*_cuda.py` tests. They run on "the available GPU" (`accel.accelerator()`).
3. Build the Windows installer as **0.2.5**.
4. Report the diffs you had to make, and your test results, back in this repository.
