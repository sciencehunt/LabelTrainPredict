# Workflows

The interface groups work into preprocessing, project setup, labelling, training, prediction and review. Advanced controls expose experimental methods and detailed settings.

## Label and train

Choose **Regions** when the goal is a semantic class for each pixel or voxel. Slice annotation and sparse strokes remain useful for this workflow. Choose **Individual objects** when each cell or structure needs a separate identity, and review complete objects before marking them finished for training.

Unknown areas are not background unless explicitly labelled or confirmed during dense review. Predictions remain separate from manual annotations until reviewed. Use representative crops from different source images and keep source groups separate when evaluating generalization.

Advanced training settings expose SE 3D U-Net and K3 choices, network size and optional flow, embedding and center-offset heads. These auxiliary outputs are experimental; their presence does not guarantee better segmentation. Model architecture is saved in the checkpoint. Changing a network requires training a compatible new model, rather than changing the architecture of an existing checkpoint at inference time.

## Inference and correction

Select a trained checkpoint, input images and a local or SSH execution target. Large volumes use tiled inference. Review the resulting segmentations, especially crop edges, touching objects and unfamiliar image conditions. Low-confidence regions are a review aid, not a calibrated measure of biological accuracy.

The inference workspace can browse saved results and create correction crops. Predictions are saved as unreviewed outputs. Advanced inference controls adjust supported decoder thresholds; network structure comes from the checkpoint.

## Preprocess

Preprocess is optional. On Windows it has a separate navigation step before Setup, so an image can be processed before creating a project. Choose a local image or a file on a connected SSH workstation. The app reads channel names and voxel calibration from metadata. Select one or more channels, review the suggested method, and compare a quick test before accepting a full run. Advanced settings expose method selection, noise reduction, sampling and voxel-size overrides.

Illumination correction estimates broad brightness variation; Mantiuk-inspired multiscale compression reduces large contrast differences while retaining local detail. Both alter intensities. Outputs are saved separately and must not replace originals for fluorophore quantification. A correction does not establish quantitative normalization or improved segmentation accuracy.

On Windows, **Use accepted image for labelling** explicitly imports an accepted, uncropped full-resolution copy. Its report and original source identity remain recorded, and both versions stay in the same source group for evaluation. This does not create reviewed labels. Keep training and inference image preparation consistent. Cropped tests and reduced-resolution previews cannot be imported through this route.

## View Output

Open original images, predictions or preprocessing results. Import dense masks from any saved LTP project, or external TIFF/NPY masks. Project annotation histories are read without modification.

Combine up to eight masks. Set each to **Include**, **Exclude** or **Ignore**, then choose union or intersection for included regions. Excluded regions are subtracted. Check physical spacing, crop origin and registration before combining masks; matching array shape alone is insufficient.

MapMask applies the combination to 3D visualization without editing image arrays. In 2D, labels remain ordinary overlays and the 3D clipping gate is removed. Very large volumes use a bounded, sampled mask overview that can miss small structures.

## Project files

Projects retain training crops, annotation history, checkpoints and versioned outputs. Typical folders include `training_images/`, `training_labels/`, `training_outputs/`, `inference_outputs/` and `models/`. The preprocessing workspace adds `preprocess_outputs/`. Keep these alongside the project metadata when backing up or moving a project.
