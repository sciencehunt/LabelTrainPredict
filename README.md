<p align="center"><img src="docs/ltp_logo.png" width="180" alt="LTP logo"></p>

# LTP | Label, Train, Predict

LTP is a desktop application for creating training data and segmenting 3D microscopy images. Annotate regions or individual objects, train a model on your data, review predictions, and process larger image volumes using local or remote compute.

Built with napari and PyTorch, LTP brings image annotation, model training and result inspection into one workflow.

## Download

| Platform | Download | Availability |
|---|---|---|
| macOS, Apple silicon | [**Download LTP for Mac (latest)**](https://github.com/sciencehunt/LabelTrainPredict/releases/latest/download/LTP-mac.dmg) | Always the newest version. Signed and notarized for macOS 14 or newer; updates itself (a window at start-up offers new versions). [Release notes](https://github.com/sciencehunt/LabelTrainPredict/releases/latest). |
| Windows 10/11, x64 | [Windows preview (0.2.5)](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-windows-parity-preview) | The newest Windows build; it is older than the Mac and Linux release until the next Windows build is published. Installer and application parts. NVIDIA CUDA is required for local instance segmentation. |
| Linux, x86_64 | [**Download LTP for Linux (latest)**](https://github.com/sciencehunt/LabelTrainPredict/releases/latest/download/ltp-linux-x86_64.tar.gz) | Always the newest version, built from the same source as the Mac release. The GPU engine has been tested; desktop validation is pending. |

The Mac and Linux links always download the newest release, so there is nothing to update after installing. The source of each release is attached to it on the [releases page](https://github.com/sciencehunt/LabelTrainPredict/releases/latest).

See [installation and hardware requirements](docs/GETTING_STARTED.md) before downloading. Preview releases may contain experimental features.

## Work with your images

- **Open:** TIFF/OME-TIFF, Imaris .ims, Olympus .oib/.oif and .oir, and more; images are shown at their physical voxel size with a scale bar.
- **Label:** paint regions on slices or annotate complete 3D objects. Review model suggestions before using them as training labels.
- **Train:** fit a segmentation model to your microscopy data. Advanced settings expose network structure and experimental flow, embedding and offset outputs.
- **Predict:** process images in blocks locally or on an SSH GPU workstation, then inspect saved results and create correction crops.
- **Preprocess:** even out uneven illumination (multiscale 3D gain field with noise reduction) or compress contrast (Mantiuk-inspired 3D), with an automatic recommendation and a side-by-side comparison before you accept. Runs on the Mac's Apple GPU or on a CUDA workstation over SSH; experimental angle-aware de-striping in Advanced. Corrected images are display copies saved separately from the originals.
- **View Output:** inspect images and predictions, and combine up to eight masks from different projects using inclusion, exclusion, union or intersection. 

Original images, manual annotations and model predictions remain separate. Unlabelled pixels are not automatically treated as background. Predictions require review before they become training data.

## Documentation

- [Install and get started](docs/GETTING_STARTED.md)
- [Annotation, training and output workflows](docs/WORKFLOWS.md)
- [Technical documentation](docs/README.md)

For a problem report, use [GitHub Issues](https://github.com/sciencehunt/LabelTrainPredict/issues) and include your operating system, app version, relevant diagnostics and reproduction steps. Share synthetic examples where possible; do not attach confidential images or credentials.

## License

LTP is distributed under the [Apache License 2.0](LICENSE). Dependencies and optional pretrained models retain their own licenses.
