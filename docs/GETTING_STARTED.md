# Install and get started

## Windows

**Windows: Smart App Control must be off to install LTP.** LTP for Windows is not code-signed yet. On Windows 11 PCs where Smart App Control is on, Windows blocks some of LTP's included files (for example PyTorch's GPU libraries) and LTP cannot start. To install: open **Settings → Privacy & security → Windows Security → App & browser control → Smart App Control settings**, choose **Off**, then run the installer. Microsoft Defender antivirus stays on. On Windows 11 with the April 2026 update (KB5083769) or later you can turn Smart App Control back on afterwards in the same place; on older versions it can only be turned back on by resetting Windows, so update Windows first if you want to switch it back on later. Signed Windows builds are planned.

Download the [Windows 0.3.3 installer](https://github.com/sciencehunt/LabelTrainPredict/releases/download/v0.3.3/LTP-windows-x64-installer.zip), extract it into a writable folder, and open **Install LTP.cmd**. Allow about 15 GB of free disk space; the installer checks the exact amount first. The installer downloads and verifies the application and its included Python runtimes. It installs in its own folder and does not replace an existing LTP installation.

For read-only inspection of a large IMS or TIFF volume, drop the image onto **Launch Fast 3D.cmd**. The main labeling workspace can briefly pause during startup; this known limitation and optional renderer requirements are documented in the release notes.

For offline installation, download every `LTP-windows-x64-app.partN` file from the same release and place them beside `install_alpha.py`. Do not mix files from different releases. Administrator rights are not required.

The 0.3.3 package passed its install, import, Analyze-worker and startup checks on Windows, and the full test suite ran on the release source. Keep Microsoft Defender antivirus on; if Windows still blocks a file after Smart App Control is off, report the exact error and blocked filename on the GitHub Issues page. Native slow-source cold-start responsiveness remains under improvement.

Local instance training, prediction and decoding require an NVIDIA CUDA GPU. Alternatively, configure an SSH GPU workstation. Local nnInteractive includes its own helper runtime and offers a separate model download on first use. Its pretrained weights have a non-commercial licence. Use copies of your projects when trying a new version.

## macOS

Download the [latest Mac DMG](https://github.com/sciencehunt/LabelTrainPredict/releases/latest/download/LTP-mac.dmg) (always the newest version), open it, and drag LTP into Applications. The packaged app is signed and notarized. It targets Apple silicon and macOS 14 or newer; 16 GB of memory or more is recommended. Available acceleration depends on the selected workflow. Remote CUDA features require a separately configured workstation.

The Mac app includes an update check. Windows and Linux update notifications link to the download page. Update checks contact GitHub; using a remote workstation also transfers the inputs required for that job to the configured server.

## Linux

Download the [latest Linux package](https://github.com/sciencehunt/LabelTrainPredict/releases/latest/download/ltp-linux-x86_64.tar.gz) (always the newest version). Use Python 3.10 to 3.12 with `venv` available.

```bash
tar xzf ltp-linux-x86_64.tar.gz
cd ltp-*-linux-x86_64
./install.sh
```

Installation creates the application environment and downloads dependencies. Start LTP from the applications menu or with `ltp`. For an SSH compute server, use `./install.sh --headless`. Instance segmentation requires CUDA in this preview.

## First project

1. Start with **Practice with sample data** to explore the tools safely.
2. Create a project and add images. Choose **Regions** for semantic segmentation or **Individual objects** for instance segmentation.
3. Select representative crops and the channels used for training.
4. Label and review your training data, train a model, then inspect its suggestions.
5. Correct mistakes and retrain before running the model on larger images.

Use the built-in Tour and help buttons for guidance. Keep a backup of your project folder, which contains annotation history, settings and run outputs.

## Compute and preview features

Remote neural training and inference run on the workstation GPU. Inference adjusts batching to available GPU memory and measured throughput. Image loading, file transfer, interface work and some bookkeeping still use the CPU; GPU execution does not mean the entire application avoids CPU work.

Preprocessing supports a local NVIDIA GPU on Windows, Apple GPU on macOS, or a configured CUDA workstation over SSH. The Windows package includes an isolated CuPy dependency overlay. Remote work requires an existing compatible workstation environment; the app does not install one automatically. Available GPU memory limits the global illumination solve. Smaller strided previews can miss fine structures.

View Output supports GPU rendering for 3D mask combinations. Mask preparation and file reading can use the CPU.

The Windows alpha includes the wgpu/Vulkan streaming engine in Large-volume 3D for supported intensity files. VisPy provides a bounded native preview. Experimental NVIDIA IndeX and Diligent options need separately installed compatible runtimes; native Windows execution with those engines is not verified.
