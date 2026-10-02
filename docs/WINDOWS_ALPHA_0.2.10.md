# Windows 0.2.10 alpha.1

This prerelease is available for testing the Windows viewer, image opening and local GPU annotation workflow.

## Install

Download **LTP-windows-x64-alpha-installer.zip** from the release, extract it, then open **Install LTP Alpha.cmd**. Allow 30 GB of free disk space. The installer downloads the numbered application parts and verifies their SHA-256 checksums before extraction. For offline use, put every `LTP-windows-x64-app.partN` from this release beside `install.ps1`.

The alpha installs separately from older versions. Open the new desktop shortcut or **Launch LTP.cmd** in its installation folder. Python and the nnInteractive helper are included. Local nnInteractive needs a supported NVIDIA CUDA GPU and offers a first-use download of its optional model weights.

## Changes

- Improved CZI opening, channel names and calibrated display.
- Progressive image previews and cached detail for Setup and image viewing.
- Updated vendor-signed Python, pandas and SciPy builds to resolve the observed nnInteractive dependency blocks.
- Bundled helper discovery, clearer startup errors and weights-only first-use setup.

## Validation and limitations

The viewer regression suite passed 26 tests, with 2 platform/opt-in skips. The helper setup and failure-recovery suite passed 6 tests. Both Python environments passed dependency consistency checks. A real nnInteractive model started on an NVIDIA RTX 3090 and completed two synthetic predictions in 0.37 and 0.30 seconds. These are operational tests, not biological accuracy results.

Smart App Control remained enabled on the tested PC. Some other native libraries remain unsigned; this is not a fully signed distribution and acceptance on fresh Windows installations has not been established. If Windows blocks a component, keep protection enabled and report the exact error. The installer does not change Windows security policies.

Use copies of projects for alpha testing. Report problems through GitHub Issues with the app version, Windows version and reproduction steps. Avoid uploading confidential microscopy data or credentials.

LTP uses Apache-2.0. Dependencies and optional model weights retain their own licences; nnInteractive pretrained weights are non-commercial.
