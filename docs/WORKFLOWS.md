# Workflows

Features depend on the installed package. The latest source preview includes Preprocess and View Output; the older packaged downloads do not yet include those workspaces.

## Label and train

Choose **Regions** when the goal is a semantic class for each pixel or voxel. Slice annotation and sparse strokes remain useful for this workflow. Choose **Individual objects** when each cell or structure needs a separate identity, and review complete objects before marking them finished for training.

Unknown areas are not background unless explicitly labelled or confirmed during dense review. Predictions remain separate from manual annotations until reviewed. Use representative crops from different source images and keep source groups separate when evaluating generalization.

Advanced training settings expose SE 3D U-Net and K3 choices, network size and optional flow, embedding and center-offset heads. These auxiliary outputs are experimental; their presence does not guarantee better segmentation. Model architecture is saved in the checkpoint. Changing a network requires training a compatible new model, rather than changing the architecture of an existing checkpoint at inference time.

## Inference and correction

Select a trained checkpoint, input images and a local or SSH execution target. Large volumes use tiled inference. Review the resulting segmentations, especially crop edges, touching objects and unfamiliar image conditions. Low-confidence regions are a review aid, not a calibrated measure of biological accuracy.

The newer inference workspace can browse saved results and create correction crops from the original image intensities. Predictions are saved as unreviewed outputs. Advanced inference controls adjust supported decoder thresholds; network structure comes from the checkpoint.

## Preprocess

The Mantiuk-inspired multiscale 3D method compresses image contrast for visualization using a global gradient-based solve. Select a channel, confirm physical voxel spacing and choose native sampling or a smaller preview. The solve runs on a configured remote CUDA workstation.

Original and corrected images are saved separately. This is a display derivative, not a claim of quantitative normalization, recovered signal or improved biological accuracy. Training inputs remain the original images. The current implementation processes one channel per run and rejects volumes that exceed its conservative GPU memory estimate.

## View Output

Open original images, predictions or preprocessing results. Import dense masks from any saved LTP project, or external TIFF/NPY masks. Project annotation histories are read without modification.

Combine up to eight masks. Set each to **Include**, **Exclude** or **Ignore**, then choose union or intersection for included regions. Excluded regions are subtracted. Check physical spacing, crop origin and registration before combining masks; matching array shape alone is insufficient.

MapMask applies the combination to 3D visualization without editing image arrays. In 2D, labels remain ordinary overlays and the 3D clipping gate is removed. Very large volumes use a bounded, sampled mask overview that can miss small structures.

## Project files

Projects retain training crops, annotation history, checkpoints and versioned outputs. Typical folders include `training_images/`, `training_labels/`, `training_outputs/`, `inference_outputs/` and `models/`. The preprocessing workspace adds `preprocess_outputs/`. Keep these alongside the project metadata when backing up or moving a project.
