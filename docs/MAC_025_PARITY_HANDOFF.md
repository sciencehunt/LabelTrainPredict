# Mac integration notes from Windows 0.2.5

Start from the same published v0.2.5-mac-source first drop. Merge `WINDOWS_025_ADDITIONS.patch`; do not overwrite any unpublished Stage3 work. Source archive includes shared app source, tests and receipts. The old CUDA-only Mac parity note from Windows0.2.4 is superseded: accel.py now preserves the Mac MPS implementation.

## Shared deltas to keep

- New inference_capacity.py: execution-local CUDA free-memory/throughput batch policy, 2.5D/3D batching and scoped OOM retries. MPS retains the Mac default batch policy, canonical mps:0 device; native MPS must be rechecked by Mac team.
- training.py: capacity state reused across block/TTA forwards, optional device_override/require_gpu, strict remote semantic/instance GPU path. Inference geometry, weights, precision and decoder contract preserved.
- remote_inference.py: versioned SSH package/worker, server GPU selection, input/output hashes, unique UUID cancellation and downloaded unreviewed results. API run_full_image_remote(ws,checkpoint,source,output_root,axes,tta,save_probability,decoder_overrides,channel_map,normalization_override,progress,cancel,source_is_remote). Existing Workstation settings are reused; no implicit environment installation.
- inference.py, remote.py, project_folders.py: capacity provenance and engine export module lists. Ensure every standalone/exported engine includes inference_capacity.py and accel.py.
- apply_panel.py: destination/settings/remote path controls, result overlay uses original uploaded image while retaining the exact remote report. Stage3 can reuse this execution API and settings.
- updater.py/update_panel.py: typed queued mode signal; prefer loaded __version__ to stale installed wheel; Windows/Linux native settings paths. Mac signature/install functions unchanged. nninteractive_client.py: correct PowerShell variable syntax.

## Validation / limitations

See RELEASE_NOTES.md and machine-readable receipts. Remote CUDA19/19 passed; actual SSH synthetic both-mode inference passed; no CPU/local neural tests. Windows Qt/NNI checks use a mocked helper. Native MPS, signed app install and actual Mac GUI must be validated on Mac. Do not report these CUDA timings as MPS results.

Run capacity GPU contracts on the matching backend; tests/test_inference_capacity_cuda.py intentionally refuses local/CPU execution and is specific to gpu-workstation CUDA. Pure metadata tests cover configuration. Preserve source-group exclusion and unknown-label rules. All model predictions remain unreviewed.

The source ZIP excludes environments, datasets, scientific checkpoints and prediction outputs. No training/model weights are included. Preserve your source-tree changes and use the delta patch for review.
