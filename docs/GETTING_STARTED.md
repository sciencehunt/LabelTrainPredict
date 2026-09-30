# Install and get started

## Windows

Download the installer ZIP and every `app.partN` file from the [Windows release](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-windows-parity-preview). Keep them in one folder, extract the installer into that folder, and run **Install Label Workflow.cmd**. The installer verifies the application checksums. Allow approximately 14 GB of temporary disk space.

The Windows application is unsigned. Local instance training, prediction and decoding require an NVIDIA CUDA GPU. Alternatively, configure an SSH GPU workstation. The instance pipeline does not silently fall back to CPU.

## macOS

Download the DMG from the [Mac release](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.4), open it, and drag LTP into Applications. The packaged app is signed and notarized. It targets Apple silicon and macOS 14 or newer; 16 GB of memory or more is recommended. Available acceleration depends on the selected workflow. Remote CUDA features require a separately configured workstation.

The Mac app includes an update check. Windows and Linux update notifications link to the download page. Update checks contact GitHub; using a remote workstation also transfers the inputs required for that job to the configured server.

## Linux

Download `ltp-0.2.5-linux-x86_64.tar.gz` from the [Linux release](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-windows-parity-preview). Use Python 3.10 to 3.12 with `venv` available.

```bash
tar xzf ltp-0.2.5-linux-x86_64.tar.gz
cd ltp-0.2.5-linux-x86_64
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

The latest source preview includes a remote CUDA/CuPy preprocessing solver. It requires an existing compatible workstation environment and does not install one automatically. Its global solve is limited by available GPU memory. Smaller strided previews can miss fine structures.

The source preview also adds GPU rendering for 3D mask combinations. Mask preparation and file reading can use the CPU.
