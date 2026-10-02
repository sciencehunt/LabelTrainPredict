# LTP 0.2.7 for Windows

> **Build withdrawn.** The Windows installer and application parts described here were removed from the release page. A rebuilt Windows package will be linked from the [front page](../README.md) when it is published. The text below is kept as a record.

The Windows app incorporates the published Mac 0.2.7 interface updates: coordinated dark and light themes, an auto-hiding Images & channels panel, a pinnable layer list, and a floating Layer settings window with a keyboard shortcut. Crop switching reuses image and label layers and defers interface changes until menu events finish.

Preprocess remains a separate optional step before Setup. Choose an image without creating a project, inspect metadata and channel names, compare corrections, and explicitly import an accepted full-resolution copy for labelling. Derivative lineage keeps the original and corrected data in the same evaluation source group. Original images and annotation histories are preserved; predictions remain unreviewed.

Per-channel analysis cards show the suggested correction, measured brightness variation and proposed settings. Advanced options expose method selection. Narrow panels wrap controls and present Z, Y and X voxel spacing separately. A remote image is analysed by its remote GPU quick test. Local preview analysis uses a reduced NumPy sample; neural training/inference and selected preprocessing execution retain their existing GPU routes.

## Validation

- 57 packaged regression tests passed, covering preprocessing, setup, model settings, inference UI, crop reuse, metadata/calibration, channel names, SSH file selection and output workflows.
- 14 packaged native Windows tests passed, including both themes, auto-hide/pin behavior, floating controls, 150 repeated crop switches, pending-paint persistence and side-by-side comparison windows.
- 14 native screenshot checks passed at 1100 and 1366-pixel window widths. No Qt warnings were captured during those visual fixtures.
- The default workstation host is empty; connection choices come from the user's own saved settings or SSH configuration.
- Existing Windows runtime and isolated CuPy overlay reused. No installed Python environment was modified.
- Three release-download reporting tests passed.

These checks use synthetic images and projects. They do not measure biological accuracy, new training performance, Mac runtime behavior or remote GPU throughput. A non-fatal PySide signal-disconnection warning occurred in the native test suite when replacing an animation callback.

## Download and install

Extract LTP-windows-x64-installer.zip and run Install Label Workflow.cmd. Missing application parts download from the matching GitHub release and are checked against SHA-256 hashes. Offline users can put the matching app.partN files beside install.ps1. Allow at least 30 GB temporary free space; older application folders are preserved as backups. The app is unsigned. Existing projects and user settings remain separate from the application folder.
