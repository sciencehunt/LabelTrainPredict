# Preprocess and View Output — 30 September 2026

The app now exposes Workspace → Preprocess, Label / train, Inference, and View output. The new modes use the user's Mantiuk-inspired 3D solver and MapMask implementation recovered read-only from `G:/D_Backup_20260924_NTFS/files/lightsheet`. Exact original source hashes are in PREPROCESS_PROVENANCE.json.

## Preprocess

- Run the original global multiscale 3D gradient solver on a configured SSH CUDA workstation. No CPU/MPS approximation and no environment installation. The Mac app can use this same remote route.
- Select a channel, explicitly confirm voxel spacing, and choose native sampling or a smaller strided preview. Native-sized global solves are refused when the conservative allocation estimate exceeds 60% of current free GPU memory; independent per-tile corrections are not substituted.
- Advanced controls expose retained broad-scale contrast, physical detail scale, detail strength, noise protection, and an existing CuPy-capable workstation Python override.
- Source snapshots, pinned worker code, UUID-scoped cancellation, verified downloads and result provenance. Original and corrected display TIFFs are stored separately and can be opened together in View Output.
- Output is a display derivative, not reviewed truth or quantitative normalization. Training inputs remain original images. The method is Mantiuk-inspired, not a claim of faithfully reproducing the paper or restoring missing SNR.

The implementation processes one selected channel per run. A preview factor greater than one currently uses explicit strided sampling, not antialiased downsampling; the UI and report disclose the possibility of missing thin structures. Larger-volume gain-field transfer and the later region-specific light-sheet correction are distinct methods and are not silently substituted for this solver.

For the existing gpu-workstation server, the tested CuPy Python is `/home/labuser/.pyenv/versions/miniconda3-3.11-25.1.1-2/envs/monai3d/bin/python`. The normal LabelWorkflow training environment does not contain CuPy. Enter the former in Advanced preprocessing's Python override; training/inference workstation settings need not change.

## View Output and multiple masks

- Open saved prediction/preprocessing folders, original images, external label TIFF/NPY files, or saved dense masks from any LTP project. Project masks are read-only SQLite snapshots with checksum verification and preserved source/crop/revision provenance. No annotation journal is opened for writing.
- Combine up to eight masks. Each is Include, Exclude or Ignore; included regions support union or intersection, with excluded regions subtracted. Each mask contributes its nonzero saved labels. Individual compartment-ID selection remains available in the original single-map MapMask controls.
- Crop origins and voxel spacing determine physical placement. Disjoint or rotated/sheared inputs are refused; users confirm that the sources share the same image coordinate system. Matching shape alone does not prove registration. Other software's masks can be imported as TIFF/NPY with the appropriate physical spacing.
- One bounded membership grid is created (at most 8,388,608 voxels). Large reference grids use a disclosed nearest-sampled overview, which can miss small features. Changing union/intersection/exclusion after building the gate updates the existing shared GPU lookup table instead of rewriting the image arrays.
- The recovered MapMask 3D shader backend is retained, with current Napari 0.7.1 / Vispy 0.16.2 support validated on Windows. Older Napari 0.6.6 / Vispy 0.15.x support remains. GPU clipping is a 3D visualization feature; switching to 2D removes that shader gate and returning to 3D reinstalls it. Labels remain visible as ordinary overlays in 2D.
- The right dock remains 320 logical pixels, with optional mask-combination controls and vertically scrollable MapMask tools. A deleted-widget callback during viewer closure was repaired.

## Verification

1. Synthetic remote preprocessing passed on gpu-workstation's NVIDIA RTX 6000 Ada. The 17 × 25 × 29 fixture completed its recorded worker processing in 1.48 s, including a 0.15 s solve; not a full-volume speed estimate. Solver converged, downloaded hashes matched, outputs were finite and original values unchanged.
2. The recovered numerical tests passed on the remote GPU: pyramid/gradient adjoints, global operator symmetry and identity reconstruction from a zero start. See GPU_NUMERICAL.json. A first receipt write failed on a NumPy scalar; JSON serialization was fixed and rerun.
3. Real Windows OpenGL rendering passed on the local RTX 3090 (display only, no local neural training/inference): changing two synthetic masks changed 48,006 screenshot channel values; restoring the rule exactly restored the image; original arrays stayed equal; 2D/3D transitions reattached the shader. See RENDERER_TEST.json. Two initial renderer-name API probes failed after the visual assertions, then the correct canvas API was verified.
4. Sixteen targeted tests cover existing inference/advanced settings/annotation contracts plus cross-project crop coordinates, union/intersection/exclusion, bounded grid geometry, read-only journal import, parameter rejection and remote preprocessing UI routing. See PACKAGED_TESTS.log for the packaged build.
5. Screenshots were inspected: the populated View Output dock fits 320 pixels (body minimum 300), and the Advanced preprocessing dialog fits 580 × 650 with vertical scrolling. This is Windows rendering evidence.

Neural engines and learned weights were not changed by this iteration. No new biological performance claim is made. CPU work still handles GUI, file IO, statistics and initial membership-grid construction; the preprocessing solve is remote CUDA and 3D visual gating uses the viewer's GPU. Native Mac rendering, signing/notarization and hardware acceptance remain untested here.
