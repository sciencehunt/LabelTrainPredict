<p align="center"><img src="docs/ltp_logo.png" width="180" alt="LTP logo"></p>

# LTP | Label, Train, Predict

LTP is a desktop application for creating training data and segmenting 3D microscopy images. Annotate regions or individual objects, train a model on your data, review predictions, and process larger image volumes using local or remote compute.

Built with napari and PyTorch, LTP brings image annotation, model training and result inspection into one workflow.

## Download

| Platform | Download | Availability |
|---|---|---|
| macOS, Apple silicon | [Mac release](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.4) | Signed application for macOS 14 or newer. |
| Windows 10/11, x64 | [Windows preview](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-windows-parity-preview) | Installer and application parts. NVIDIA CUDA is required for local instance segmentation. |
| Linux, x86_64 | [Linux preview](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-windows-parity-preview) | Download the Linux archive. The GPU engine has been tested; desktop validation is pending. |

For source packages, see the [source preview](https://github.com/sciencehunt/LabelTrainPredict/releases/tag/v0.2.5-workspaces-preview). Download the installer for your platform to run the application.

See [installation and hardware requirements](docs/GETTING_STARTED.md) before downloading. Preview releases may contain experimental features.

## Work with your images

- **Label:** paint regions on slices or annotate complete 3D objects. Review model suggestions before using them as training labels.
- **Train:** fit a segmentation model to your microscopy data. Advanced settings expose network structure and experimental flow, embedding and offset outputs.
- **Predict:** process images in blocks locally or on an SSH GPU workstation, then inspect saved results and create correction crops.
- **Preprocess:** use Mantiuk-inspired 3D contrast compression on a remote CUDA workstation. Corrected images are saved separately from the originals. Available in the latest source preview.
- **View Output:** inspect images and predictions, and combine up to eight masks from different projects using inclusion, exclusion, union or intersection. Available in the latest source preview.

Original images, manual annotations and model predictions remain separate. Unlabelled pixels are not automatically treated as background. Predictions require review before they become training data.

## Documentation

- [Install and get started](docs/GETTING_STARTED.md)
- [Annotation, training and output workflows](docs/WORKFLOWS.md)
- [Technical documentation](docs/README.md)

For a problem report, use [GitHub Issues](https://github.com/sciencehunt/LabelTrainPredict/issues) and include your operating system, app version, relevant diagnostics and reproduction steps. Share synthetic examples where possible; do not attach confidential images or credentials.

## License

LTP is distributed under the [Apache License 2.0](LICENSE). Dependencies and optional pretrained models retain their own licenses.
