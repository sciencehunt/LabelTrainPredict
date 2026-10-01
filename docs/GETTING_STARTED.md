# Install and get started

## Windows

Download the [Windows installer ZIP](https://github.com/sciencehunt/LabelTrainPredict/releases/latest/download/LTP-windows-x64-installer.zip), extract it into a writable folder, and run **Install Label Workflow.cmd**. It downloads the required application parts and verifies their SHA-256 checksums. Allow at least 30 GB of temporary disk space, plus space for any previous installation retained as a backup.

For offline installation, download every `LTP-windows-x64-app.partN` file from the same release and place them beside `install.ps1`. Do not mix files from different releases. Administrator rights are not required.

The Windows application is unsigned. Local instance training, prediction and decoding require an NVIDIA CUDA GPU. Alternatively, configure an SSH GPU workstation. The instance pipeline does not silently fall back to CPU.

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
