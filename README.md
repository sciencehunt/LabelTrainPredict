<p align="center"><img src="docs/ltp_logo.png" width="180" alt="LTP logo"></p>

# LTP — Label, Train, Predict

**LTP** (Label Train Predict, formerly *Label Workflow*) is a desktop app for labelling 3D microscopy images and training your own segmentation model, without writing code. Label a few regions, train, correct the model's suggestions, and run the final model on whole images of any size.

It is built on [napari](https://napari.org) and PyTorch and runs on your own computer: on the Apple GPU of a Mac, on an NVIDIA GPU (CUDA) on Windows and Linux, or on the CPU. Your images never leave your machine unless you choose to train or predict on your own workstation.

The Mac app is called LTP from version 0.2.2. The Windows 0.2.5 parity preview uses LTP branding; its installer and existing settings retain the former *Label Workflow* name.

## Download

| System | Download | Notes |
|---|---|---|
| **Mac** (Apple silicon) | [Latest release](https://github.com/sciencehunt/LabelTrainPredict/releases/latest): `LTP-<version>.dmg` | Signed and notarized; updates itself |
| **Windows** 10/11 x64 | [LTP 0.2.5 Windows parity preview](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-windows-parity-preview): installer zip + app parts | Published Mac 0.2.5 features, SE/K3/auxiliary heads, remote GPU inference |
| **Linux** x86_64 | [LTP 0.2.4 network-options preview](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.4-windows-network-preview): `ltp-0.2.4-linux-x86_64.tar.gz` (same features as Windows 0.2.4), or `ltp-<version>` from the [latest release](https://github.com/sciencehunt/LabelTrainPredict/releases/latest) | Installs its packages from the internet; CUDA required for instances in 0.2.4 |

### Mac

- **Requirements:** a Mac with Apple silicon (M1 or newer) and macOS 14 Sonoma or newer.
- **Memory:** 16 GB or more is recommended. 8 GB Macs work with an automatically reduced network.
- **Install:** open the DMG and drag **LTP** into **Applications**. The app is signed and notarized by Apple, so it opens without security warnings.

### Windows

- Download the installer ZIP and all app parts from the [0.2.5 Windows parity preview](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-windows-parity-preview) into one folder. Unzip the installer there and run **Install Label Workflow.cmd**. Parts are checksum-verified; about 14 GB temporary disk space is advisable.
- The app is unsigned. Instance training, prediction and decoding require an NVIDIA CUDA GPU; there is no silent CPU fallback for this path. Semantic workflows have separate device support.
- **Advanced training:** SE U-Net or custom K3, optional SE attention, width/depth presets or Custom, individually enabled flow/embedding/offset heads, global and per-head loss weights. These auxiliary heads remain experimental.
- **Advanced inference:** inspect checkpoint structure and override only decoder thresholds. Changing the network requires a newly trained checkpoint.
- **Remote inference:** choose Workstation (SSH) in Run on full images. The server selects its available GPU and tunes tile batching against measured speed/free memory; the client receives verified, unreviewed results. Neural inference never falls back to CPU on this route.
- This preview preserves projects and the Mac update feed. It matches the published first Mac 0.2.5 source handoff; the planned Stage 3/results-browser second drop is not included yet. See [release and test notes](docs/WINDOWS_025_PARITY.md) and [Mac merge notes](docs/MAC_025_PARITY_HANDOFF.md).

### Linux

- **Requirements:** x86_64 with Python 3.10–3.12 and `venv` (Ubuntu: `sudo apt install python3.12-venv`). Tested target: Ubuntu 22.04/24.04. An NVIDIA GPU is used automatically when `nvidia-smi` works.
- **Install** (no root needed; downloads about 4 GB of Python packages, including PyTorch, the first time):

  ```bash
  tar xzf ltp-0.2.4-linux-x86_64.tar.gz
  cd ltp-0.2.4-linux-x86_64
  ./install.sh
  ```

  Start **LTP** from the applications menu or with `ltp` (`label-workflow` also works). A minimal system may need the usual Qt/X11 libraries: `sudo apt install libxcb-cursor0 libgl1 libegl1 libxkbcommon-x11-0`.
- **GPU server:** `./install.sh --headless` installs only the training and inference engine, for use with *Train on workstation*.
- **Uninstall:** `~/.local/share/label-workflow/uninstall.sh`. Your projects and settings are kept.
- **0.2.4 preview:** the same app code as Windows 0.2.4 (all 38 source files identical), with the same Advanced training options. Instance training, prediction and decoding require an NVIDIA CUDA GPU. Use the same commands with the `ltp-<version>` package from the latest release for the Mac-matched version.
- **Status:** the headless engine is tested on Ubuntu 24.04 with an NVIDIA GPU (0.2.4: SE U-Net with flow/embedding/offset heads and K3, trained and predicted with the CUDA decoder). The full desktop install on Linux has not yet been tested on a Linux desktop.

### Updates

**Mac:** from version 0.2.2 on, the app checks this page for new versions, at most every few hours. When a new version is available, an **⬆ Update** button appears in the top bar. You can also use **Help → LTP: Check for updates…**.

Before anything is installed, the update is verified in three ways:
- the file checksum must match;
- the app must carry the developer's Apple signature;
- Apple's notarization must be valid.

Your project is saved, the app restarts on the same project, and the previous version is kept so it can be restored. The update check only reads this page; nothing about you or your data is sent. Versions 0.2.1 and older (then called *Label Workflow*) need a one-time manual install of the latest version; projects and settings carry over.

**Windows and Linux:** from 0.2.2 on, the app shows an **⬆ Update** button that opens this page when a new version is out; download and install it from here. Installing over an existing version replaces it only after the new one is fully unpacked.

## What it does

**Stage 1 · Setup**
- **Choose the kind of labelling.** *Regions* covers areas and structures such as vessels or tissue types. *Individual objects* covers nuclei and cells, where each gets its own ID for counting and measuring.
- **Add images.** Add TIFF, OME-TIFF, Imaris (.ims), Olympus (.oib) and other files or folders, or connect a dataset on another computer over SSH. Original files are never changed.
- **Crops.** 🎲 *Random* crops are spread across positions, depths and brightness levels, even inside a single large light-sheet image. You can also place each crop yourself.
- **Where to train.** Train on this computer, or on a GPU workstation or server over SSH. SSH uses key-based login and no password is stored.

**Stage 2 · Training**
- **Round 1 (2.5D).** Paint single slices, using *Complete masks* or fast *Quick strokes*. Train, then accept and correct the model's suggestions slice by slice.
- **Round 2 (3D).** Work on whole volumes. Accept a whole-stack prediction at once, jump to the **most uncertain areas**, and retrain.
- **Finished objects (3D)** for instance segmentation. Mark objects ✓ Finished; ◧ Complete shows exactly what training will use. The **☰ Objects list** has sortable measurements, jump-to-object and multi-delete.
- **Assisted labelling:**
  - **nnInteractive:** click an object and get its 3D outline;
  - **Smart select** (micro-SAM);
  - **Cellpose-SAM:** outline every nucleus in one pass.
- **Separating touching objects.** Tuned automatically on your labels; a live *Split* slider fine-tunes it.

**Run on full images**
- Label every voxel of whole images, either one file or a whole folder. Big volumes are processed in blended blocks, so there are no tile seams.
- Each run saves a prediction, a probability map and a per-object volume table.
- The best 2.5D and 3D models are kept in the project's `models/` folder, together with a script to run them without the app.

A built-in **Tour** walks through every step, and the **?** button explains each term in plain language. *Practice with sample data* creates a small synthetic project to try everything safely.

## Project folder

```
MyProject/
  training_images/     crops used for labelling
  training_labels/     your labels
  training_outputs/    training runs and checkpoints
  inference_outputs/   full-image predictions, probability maps, object tables
  models/              best_2.5D_<channels>.pt, best_3D_<channels>.pt, run_inference.py
```

## Third-party components

LTP uses napari, PyTorch, Qt (PySide6), scikit-image, SciPy, tifffile and other open-source packages under their own licences.

Optional helpers are downloaded only when you first use them, and only after you agree:
- **nnInteractive** (weights under CC BY-NC-SA 4.0, **non-commercial use only**);
- the **Segment Anything / micro-SAM** models;
- **Cellpose-SAM**.

## Licence

Apache License 2.0. See [LICENSE](LICENSE).
