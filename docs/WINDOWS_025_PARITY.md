# Windows build notes

## Included

This Windows build incorporates the published **v0.2.5-mac-source** first handoff (ZIP SHA-256 `d114789e024d45cfc0b84211ff008a3ec96863a924b63766d6c4a5be3adeb5b3`). It includes nnInteractive's selected training channels, legacy crop display names, shared CUDA/MPS engine, window-first tiled extraction, workstation setup and update notices. Windows-specific fixes cover queued startup notification/busy behavior, running-code version detection and native settings locations.

Advanced settings retain SE U-Net and K3, optional SE attention, custom width/depth and independently weighted flow, embedding and offset supervision. Inference reads the architecture from the checkpoint; editing architecture requires retraining. Auxiliary heads remain experimental.

**Run on full images** now offers **This computer** or **Workstation (SSH)**. Local images are uploaded; existing absolute workstation paths or matching `ssh://host/path` sources run where they reside. Checkpoint, engine and inputs are pinned. Verified predictions and a provenance report return locally as unreviewed outputs. Uploaded local images can be reopened under the prediction overlay.

The remote worker chooses the CUDA GPU with the most currently free VRAM in automatic mode, or honours an explicitly selected GPU. It measures batch throughput on that server and uses its available GPU/host memory, keeping a memory reserve. 2.5D and 3D tile batching preserve geometry and precision. OOM halves the batch; a single-tile failure is explicit. Remote neural inference and instance decoding never fall back to CPU. File reading, transfers, orchestration and TIFF writing still use the CPU.

## Actual validation

- 19 selected tests passed on the otherwise-idle **gpu-workstation RTX 6000 Ada 48 GB**, PyTorch2.6.0+cu126: SE/K3 forward/backward, auxiliary targets/loss, unknown-label masking, short train/reload, legacy checkpoint, GPU decoder/linking, full-image TIFF/provenance, both-mode batch equivalence, autotune and OOM/no-CPU guards. 0 skips. No local/CPU neural execution.
- Actual Windows-to-SSH-to-GPU-to-Windows runs passed: uploaded synthetic 3D instance image and existing remote 2.5D semantic image. Total transport/run/download was **5.08s** and **4.30s**, respectively; reported inference was0.6s and0.3s. The checkpoint deliberately saved `device=cpu`; the server override correctly ran CUDA. Source/checkpoint hashes unchanged, outputs unreviewed.
- Real-Napari advanced settings/routing/legacy configuration tests:6 passed; added uploaded-image-overlay check:1 passed. Independent Qt/updater/NNI/channel suite:17 passed,7 expected platform/dependency skips,0 failures. Transport/metadata tests:19 passed. NNI was mocked, not a new neural accuracy test.
- Packaged Windows source:25 UI/updater/transport/metadata tests passed; a misspelled capacity test module caused one runner import error, corrected by running the actual module separately (7/7 passed). This was a test-selection typo, not an application failure; both logs are retained.
- The complete inherited Mac test suite was not rerun: it includes CPU neural reference tests, contrary to the requested GPU-only neural testing. Native MPS/Finder/signing remains the Mac team's evidence, not a Windows claim.

## Measured capacity benchmark

Synthetic random-weight SE models, fixed FP32/tile geometry, three paired timing repeats after warmup on the remote GPU. These measure prediction and blending; exclude decoder, transfers and file IO. Accuracy was not measured. Results match batch1 within5e-5 absolute/relative tolerance.

| Mode | Batch1 median | Adaptive cached median | Selected batch | Adaptive allocated peak | First adaptive run incl. tuning |
|---|---:|---:|---:|---:|---:|
| 2.5d | 0.129 s | 0.074 s | 4 | 171 MiB | 0.326 s |
| 3d | 0.103 s | 0.114 s | 1 | 682 MiB | 0.499 s |

2.5D improved about1.75×. 3D chose batch1 because larger batches were slower; the repeated cached run was about11% slower than the fixed-batch median, so this small benchmark does **not** establish a 3D speed gain. More VRAM use alone is not a speed target. Automatic tuning has a startup cost, recorded separately; choices are reused across compatible blocks/TTA.

## Limits and installation

This is parity with the **published first Mac handoff**, not unreleased future work. That handoff explicitly defers Stage3 Inference, results browser and difficult-area-to-new-crop workflow to a second drop. None was available at the parity review. Existing Run on full images is supported here.

Download the installer ZIP and every app.partN beside it; extract the installer there and run Install Label Workflow.cmd. It verifies part hashes. Use a separate destination to preserve an older app. Existing projects/data and scientific checkpoints are not packaged or changed. The Windows build is unsigned. Dependencies were copied from the existing runtime; none were installed/updated during this work.

Remote access uses existing OpenSSH/key configuration and an already prepared Python environment. Absolute workstation work folders are recommended; `~/...` is rejected clearly because shell/scp expansion differs. Cancellation is cooperative between GPU operations; an in-progress upload/download currently finishes before cancellation is observed. Remote snapshots are retained for provenance. Remote-only originals are not automatically downloaded merely to overlay a result locally.

Windows publication uses a separate prerelease tag, preserving the Mac stable release/update feed.

## Final distribution verification

The Windows installer passed in a fresh disposable directory, with shortcuts and registry changes disabled. All40,599 installed archive files matched size/CRC; all50 manifest source/launcher files matched SHA-256. Installed app and updater both reported0.2.5 from the intended source directory. All seven primary GitHub assets matched local SHA-256 and size. A separate INSTALLER_VERIFICATION.json receipt accompanies the release.
