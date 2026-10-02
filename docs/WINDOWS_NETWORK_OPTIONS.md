# LTP 0.2.4 :  Windows network-options preview

> **Build withdrawn.** The Windows installer and application parts described here were removed from the release page. A rebuilt Windows package will be linked from the [front page](../README.md) when it is published. The text below is kept as a record.

This Windows preview publishes the SE/K3 and auxiliary-head work that was present in a separate local build but absent from the inspected public v0.2.3 Linux wheel. It does not replace the signed Mac v0.2.3 release or its updater manifest.

## Advanced training options

- SE residual U-Net and custom MedNeXt-inspired K3.
- Optional SE channel attention on either 3D instance backbone.
- Network-size presets or custom base filters (8-64) and resolution levels (3-7).
- Flow, embedding and center-offset auxiliary heads, individually enabled, with global and per-head loss weights.
- GPU basin decoding with foreground and split thresholds; all settings saved with the project/trained checkpoint.

New 3D instance projects default to SE16/depth4, XY2 and all three experimental heads, as requested. They have not consistently improved accuracy in the short paired trial. Uncheck all three for the original-head model. Changing network structure requires training a new model. This is configuration of supported backbones, not a general layer editor or support for every research prototype.

Advanced inference displays the saved model structure and permits explicit decoder-threshold overrides. It cannot change trained width/depth/heads. Prediction outputs remain unreviewed. Whole-object supervision applies to instance workflows; semantic/2.5D slice workflows remain separate.

## Install on Windows

Download `LTP-0.2.4-windows-x64-installer.zip` and every `LTP-0.2.4-windows-x64-app.partN` into the same folder. Unzip the installer there and run `Install Label Workflow.cmd`. The installer verifies each part and the joined archive. About 14 GB temporary free space is advisable for downloaded parts, joined archive and installed runtime. The app is unsigned. Existing projects and data are not included or modified.

Instance training/prediction/decoding require NVIDIA CUDA; no silent CPU fallback. Some input preparation, file I/O and descriptive export statistics run on the host. The new CUDA basin changes historical CPU watershed splitting, so old weights may produce different object IDs. CUDA instance models are not native-MPS Mac models.

`LTP-0.2.4-network-options-source.zip` includes source, targeted tests, diff and Mac parity notes, without runtime, model weights or scientific data. It is a source/handoff archive, not a Mac application. Read `MAC_NETWORK_PARITY.md` before porting: preserve the Mac signing/updater/nnInteractive fixes and implement remote GPU inference as well as remote training. Native Mac runtime parity is not claimed.

## Verification

- Synthetic real-Napari Advanced UI: defaults, custom capacity, per-head weights, persistence and both workflow types pass.
- Remote RTX6000 Ada: custom SE/K3 × SE on/off, all three heads, finite backward and strict model-state reload pass. No local neural execution.
- Prior unchanged backend integration: 15 remote CUDA checks, including old scientific SE/K3 weight compatibility and real multiblock CUDA checkpoint-to-TIFF; 9 metadata/package checks.
- Full archive/part hashes and disposable Windows installer verification are recorded in the attached release verification receipt. Mac behavior is untested by this Windows preview.

Research-use preview; accuracy is dataset-dependent. No pretrained scientific checkpoint is bundled. Existing dependency/model license obligations still apply.
