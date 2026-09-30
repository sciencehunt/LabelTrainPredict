# Network-options parity handoff — Windows 0.2.4 preview

30 September 2026. Target repository: sciencehunt/LabelTrainPredict. The public v0.2.3 Linux wheel was downloaded and inspected: it contains none of `mednext_k3`, `auxiliary_heads`, `cuda_basin_v1`, or `se_attention` in widget/training, and has no architectures module. This is evidence about that Linux asset, not a binary inspection of the signed Mac DMG. The local 0.2.2 Windows build had the new backends but had not been published with that release.

## Requested feature contract

All new controls live in Advanced training settings. New 3D instance projects start with the original SE U-Net baseline: width16, depth4, XY2, SE on, flow+embedding+offset heads. Combined heads are explicitly experimental; the short paired test did not consistently improve accuracy. Existing explicit project settings remain respected.

- Backbones: `se_unet`, `mednext_k3` (custom MedNeXt-inspired K3, not official pretrained MedNeXt).
- SE attention independently on/off for either 3D instance backbone. Explicit K3 selection starts width32/depth4/SE off; user can enable SE.
- Network-size presets and Custom base width8–64 / depth3–7. Capacity changes require a newly trained checkpoint. Later levels cap channels at320. Custom width must not be silently raised to16 in Round2.
- Heads independently enabled: flow3, embedding8, offset3. Global auxiliary weight and individual nonnegative multipliers; effective weight is their product. Zero multiplier retains the head with no supervision; unchecking removes it.
- CUDA basin v1 decoder; foreground threshold and split prominence. The three extra heads supervise training; the supported primary decoder still uses foreground/distance/boundary. Direct flow/embedding/voting decoders are research experiments and are not offered as production app choices.
- Inference shows checkpoint-owned architecture, dimensions, attention, heads and weights read-only. Only explicit decoder thresholds and existing TTA controls may override inference behavior. Persist/audit overrides separately from checkpoint metadata.
- No arbitrary network-code import or graphical layer editor. Other overnight prototypes are not supported app architectures.

## Files to port together

Use source archive and SHA256 inventory shipped with this release; do not replace the Mac tree wholesale.

Backend: models.py, architectures.py, auxiliary.py, cuda_instances.py, training.py. Integration: widget.py, training_bridge.py, apply_panel.py, inference.py, remote.py, project_folders.py. Portable engine module lists must include every new backend module. Preserve the old scientific checkpoint parameter layout when heads are empty and SE is on. Preserve strict configuration/architecture metadata validation.

New preview-specific edits relative to this agent's prior Windows baseline are in `NETWORK_OPTIONS_CHANGES.patch`. The complete source archive includes the earlier SE/K3/GPU integration; that patch alone does not bring an old Mac source tree to parity.

Project settings: `ui_settings.net_size='custom'`, `custom_width`, `custom_depth`; `ui_settings.instance_training` contains architecture, se_attention, auxiliary_heads, auxiliary_weight, auxiliary_loss_weights, instance_decoder and scalar decode settings. Existing configs without per-head weights default each to1. TrainingConfig and checkpoint format1 persist actual width/depth and all head weights. Keep old checkpoint loading compatible.

## Mac backend contract: do not fake CUDA/MPS parity

The new auxiliary-target/training/instance decoding path requires CUDA. Apple silicon has no CUDA. For feature parity, expose these options and route their training and prediction to a remote NVIDIA workstation; disable incompatible local actions with a clear explanation. The current Windows full-image dialog is a local inference route: Mac needs a real remote inference job transport before advertising full-image GPU parity. Its existing remote-training path alone is insufficient.

Do not silently switch the CUDA instance path to CPU or MPS. A native MPS implementation is a separate engineering and validation project. Preserve Mac's existing supported semantic/2.5D workflows and distinguish them visibly. Do not regress v0.2.3's interpreter signing, nnInteractive environment validation/repointing, updater identity, notarization or app naming. Do not replace `latest.json` with the Windows preview. Build/sign/notarize the Mac update on the Mac using its existing pipeline.

## Scientific behavior and limitations

Unknown voxels are never background by default. Suggestions remain versioned and unreviewed. Auxiliary learning requires finished-object supervision for positive partially reviewed volumes; partially labeled slices cannot silently become full instances. Semantic and 2.5D slice routes keep their existing recipe. Basic augmentation only with heads; reject incompatible strong augmentation explicitly. Require consistent voxel spacing for vector targets.

CUDA marker-basin is a changed algorithm from the historical CPU watershed, not a bitwise-equivalent acceleration. CUDA block linking and ID compaction are part of the required path. Some input preparation, disk I/O and export statistics remain on CPU. Enabled heads also select versioned padded visible-object CUDA targets; head-on/off in production is not a pure loss ablation. The controlled pilot used matched targets.

## Verification to reproduce

- Synthetic real-Napari `test_advanced_model_ui.py`: defaults, K3 preset, custom12/3, per-head weights, persistence, Round2 preserving width, semantic/2.5D isolation, read-only checkpoint structure and threshold overrides. Windows2/2 passed; no local neural execution.
- Remote RTX6000 Ada `test_network_customization_cuda.py`: SE/K3 × attention off/on, custom12/3, all3 output shapes, finite backward and strict state reload passed. No claim that every width/depth is performance-benchmarked.
- Earlier backend/inference validation:15/15 remote CUDA tests, including real old SE/K3 scientific checkpoint forwards, train/save/reload, unknown-gradient masks, GPU basin, ID linking and real multiblock checkpoint-to-TIFF. Metadata/package9/9 and packaged-UI2/2 passed.
- On Mac: test real Napari Advanced visibility/layout, saved settings across restart, both project types, remote job exact config identity, cancel/error paths, returned checkpoint/prediction provenance and full-image remote inference. Preserve source images/annotations/checkpoints and append execution log. No Mac runtime or MPS performance is certified by these Windows/Linux checks.

## Release boundaries

Windows v0.2.4 network preview is a separate pre-release; Mac v0.2.3 remains the stable/latest updater target. Do not promote a Mac build as feature-parity until the above checks and remote-inference route pass. Mac agent should return source diffs, tests and signed release artifacts; never return scientific datasets or model checkpoints. Existing commercial licensing qualifications remain unchanged.
