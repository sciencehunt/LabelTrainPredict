# LTP 0.2.8 for Windows

> **Build withdrawn.** The Windows installer and application parts described here were removed from the release page. A rebuilt Windows package will be linked from the [front page](../README.md) when it is published. The text below is kept as a record.

This update improves remote image selection, preprocessing previews and workflow controls.

- Open images through a configured SSH workstation without an incorrect address-mismatch error. Metadata inspection uses the selected preprocessing runtime.
- Preview large Imaris images using their stored image pyramids, with calibrated voxel spacing. Draw a native-resolution XY test region that retains the full Z depth.
- See the local or remote execution destination before starting a test. Preview acceptance explicitly starts processing the full image.
- Keep preprocessing controls consistent with the active job. Cancel remains available, and error messages stay visible when the workflow panel is unpinned.
- Avoid stale crop selections and misleading inactive-region summaries. Multichannel results scroll without compressing the image picker or buttons.
- Compare original and processed images with appropriate sampling descriptions and access full channel names through tooltips.

## Install

Download `LTP-windows-x64-installer.zip`, extract it into a writable folder, and run `Install Label Workflow.cmd`. The installer downloads the application parts from this exact release and verifies their SHA-256 checksums. Allow at least 30 GB of temporary disk space, plus space for a retained previous installation. No administrator rights are required. The installer is not code-signed.

For an offline installation, put all `LTP-windows-x64-app.partN` files from this release beside `install.ps1` before running it. Do not mix parts from different releases. Existing projects and settings are preserved; close LTP before updating an existing installation.

Local GPU workflows require a compatible NVIDIA GPU and driver. A configured SSH GPU workstation can process remote images. No personal workstation configuration, scientific images, annotations or model checkpoints are included.

## Working with previews

Reduced-resolution and cropped outputs are previews. Review a full-image result before using it downstream. Preprocessing changes intensities; retain original images for fluorophore quantification. Model suggestions remain separate and unreviewed.

Full native output can require substantially more disk space than the compressed input. Check available space on the selected workstation before processing a large image. GPU acceleration varies by method; this release does not claim that every numerical operation runs on the GPU.

Remaining interface refinements include a more compact header, consistent text-size scaling and restoring the saved rectangle when reopening the crop editor.

This release contains the Windows application and its corresponding source. Mac and Linux downloads remain available separately from the project home page.
