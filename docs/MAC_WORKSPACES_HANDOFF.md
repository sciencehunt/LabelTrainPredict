# Mac workspace integration handoff

This source snapshot extends the published Mac v0.2.5 first drop with previous Windows parity, the compact Inference stage and the new Preprocess/View Output workspaces. Preserve any unpublished Mac changes. The LF patch is checked against the published first drop; do not blindly apply it over later Mac edits.

New modules: preprocess.py, preprocess_panel.py, remote_preprocess.py, tonemap_cuda.py, output_view.py, multi_masks.py and `_vendor/mapmask/`. Keep all of them in the bundle, including the MapMask BSD LICENSE. The preprocessing module imports CuPy only inside the remote worker, so app startup on a Mac does not require CuPy.

`__main__.py` installs the Workspace menu. Custom Mac entry points that construct their own viewer/widget must also call `install_workspace_menu(viewer, widget)` after normal layout setup. Completed inference viewers now attach Output controls. All models/advanced network options from the prior handoffs remain intact.

Preprocess uses an existing CUDA/CuPy workstation Python. The tested gpu-workstation path is recorded in WORKSPACES_REVIEW.md. This Python override is separate from training/inference settings. Do not install CuPy automatically or claim an MPS port. Source images and scientific annotations remain unchanged.

The original shader gate was version-pinned. Its current supported pairs are Napari 0.6.6/Vispy 0.15.x and Napari 0.7.1/Vispy 0.16.2. Only the latter was newly exercised on Windows RTX 3090 OpenGL. Validate a native Mac OpenGL viewer before claiming Mac GPU gate support; unsupported versions fail visibly without rewriting image data.

Native acceptance checklist: Workspace menu visible; SSH preprocessing and cancellation; original/corrected output comparison; import masks from two disposable projects with different crop origins; confirm registration; union/intersection/exclusion; 2D/3D reattachment; close viewer without delayed callback errors; 320-pixel right dock at Retina scaling. Confirm packaged LICENSE and no missing dynamic imports before signing/notarizing.

The source handoff is not a native Mac executable. This iteration does not replace the stable Mac update feed.

The published first-drop archive included packaging/macos/build_app.sh but omitted the mac/requirements-mac.txt file it references. Apply this handoff to the Mac team's existing source checkout and retain its verified requirements file; this ZIP is an integration snapshot, not a standalone dependency/bootstrap distribution. Do not invent or install replacement pins automatically.
