# Label Workflow — label, train, predict

**Label Workflow** is a desktop app for labelling 3D microscopy images and training your own segmentation model, without writing code. Label a few regions, train, correct the model's suggestions, and run the final model on whole images of any size.

It is built on [napari](https://napari.org) and PyTorch and runs on your own computer, on the Apple GPU of your Mac. Your images never leave your machine unless you choose to train on your own workstation.

## Download

**[⬇ Download the latest version for Mac](https://github.com/sciencehunt/LabelTrainPredict/releases/latest)**. Pick `Label-Workflow-<version>.dmg` under *Assets*.

- **Requirements:** a Mac with Apple silicon (M1 or newer) and macOS 14 Sonoma or newer.
- **Memory:** 16 GB or more is recommended. 8 GB Macs work with an automatically reduced network.
- **Install:** open the DMG and drag **Label Workflow** into **Applications**. The app is signed and notarized by Apple, so it opens without security warnings.

### Updates

From version 0.2.2 on, the app checks this page for new versions, at most every few hours. When a new version is available, an **⬆ Update** button appears in the top bar. You can also use **Help → Label Workflow: Check for updates…**.

Before anything is installed, the update is verified in three ways:
- the file checksum must match;
- the app must carry the developer's Apple signature;
- Apple's notarization must be valid.

Your project is saved, the app restarts on the same project, and the previous version is kept so it can be restored. The update check only reads this page; nothing about you or your data is sent.

Versions 0.2.1 and older need a one-time manual install of the latest version.

## What it does

**Stage 1 · Setup**
- **Choose the kind of labelling.** *Regions* covers areas and structures such as vessels or tissue types. *Individual objects* covers nuclei and cells, where each gets its own ID for counting and measuring.
- **Add images.** Add TIFF, OME-TIFF, Imaris (.ims), Olympus (.oib) and other files or folders, or connect a dataset on another computer over SSH. Original files are never changed.
- **Crops.** 🎲 *Random* crops are spread across positions, depths and brightness levels, even inside a single large light-sheet image. You can also place each crop yourself.
- **Where to train.** Train on this Mac, or on a GPU workstation or server over SSH. SSH uses key-based login and no password is stored.

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

Label Workflow uses napari, PyTorch, Qt (PySide6), scikit-image, SciPy, tifffile and other open-source packages under their own licences.

Optional helpers are downloaded only when you first use them, and only after you agree:
- **nnInteractive** (weights under CC BY-NC-SA 4.0, **non-commercial use only**);
- the **Segment Anything / micro-SAM** models;
- **Cellpose-SAM**.

## Licence

Apache License 2.0. See [LICENSE](LICENSE).
