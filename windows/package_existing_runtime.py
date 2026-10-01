"""Build a separate Windows app from an existing runtime, without pip/install changes."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[1]

def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for data in iter(lambda:f.read(1024*1024),b''):h.update(data)
    return h.hexdigest()

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--output',required=True)
    ap.add_argument('--runtime',default=str(ROOT/'dist-windows/Label Workflow/python'))
    ap.add_argument('--use-copied-runtime',action='store_true')
    args=ap.parse_args();out=Path(args.output).resolve();runtime=Path(args.runtime).resolve()
    if ROOT not in out.parents or out==ROOT/'dist-windows/Label Workflow':
        raise ValueError('Choose a new build directory inside this workspace.')
    if not (runtime/'python.exe').is_file():raise ValueError('Existing Windows runtime required; no environment is installed automatically.')
    if (out/'src').exists() or (out/'BUILD_MANIFEST.json').exists():raise FileExistsError('Existing source build is preserved; choose a new output.')
    if args.use_copied_runtime:
        if not (out/'python/python.exe').is_file():raise ValueError('Copied runtime missing.')
        if sha(out/'python/python.exe')!=sha(runtime/'python.exe'):raise ValueError('Runtime executable differs from supplied source.')
    else:
        out.mkdir(parents=True,exist_ok=False);shutil.copytree(runtime,out/'python')
    shutil.copytree(ROOT/'src',out/'src',ignore=shutil.ignore_patterns('__pycache__','*.pyc','*.egg-info'))
    shutil.copy2(ROOT/'windows/icon.ico',out/'icon.ico')
    launch='''from pathlib import Path
import sys
root=Path(__file__).resolve().parent
sys.path.insert(0,str(root/'src'))
from napari_label_workflow.__main__ import main
main()
'''
    (out/'launch_app.py').write_text(launch,encoding='utf-8')
    (out/'Start Label Workflow.bat').write_text('@echo off\nsetlocal\ncd /d "%~dp0"\nstart "" "%~dp0python\\pythonw.exe" -B "%~dp0launch_app.py" %*\n',encoding='ascii')
    (out/'Run Diagnostics.bat').write_text('@echo off\nsetlocal\ncd /d "%~dp0"\n"%~dp0python\\python.exe" -B "%~dp0launch_app.py" %*\nif errorlevel 1 pause\n',encoding='ascii')
    (out/'README.txt').write_text('LTP Workspaces 0.2.7\n\nDouble-click Start Label Workflow.bat. Run Diagnostics.bat keeps launch errors visible.\n\nCreate reviewed training data, train semantic or instance segmentation models, and inspect saved predictions. Preprocess is a separate optional step before Setup. It compares illumination and contrast methods before a full run. Accepted full-resolution copies can be explicitly chosen for labelling. Advanced options include noise reduction, experimental de-striping, model architecture and auxiliary heads.\n\nPreprocessing uses an available NVIDIA GPU locally or an SSH GPU workstation. Local CuPy can use the existing optional preprocessing runtime; otherwise the PyTorch CUDA route is available. Connection choices come from your own settings and SSH config. No workstation is preconfigured.\n\nCorrection changes intensity values. Use original images for fluorophore quantification. Train and predict with consistent image preparation. Predictions are separate and unreviewed. Existing projects and checkpoints retain their saved configuration.\n\nThis build reuses an existing Windows runtime without installing or changing environments. Images, annotations, scientific checkpoints and private connection settings are not bundled.\n',encoding='utf-8')
    for name in ('LICENSE','NOTICE','THIRD_PARTY_NOTICES.md'):
        candidate=ROOT.parent/'LabelTrainPredict-github'/name
        if candidate.is_file():shutil.copy2(candidate,out/name)
    oir=ROOT/'dist-windows/LTP Workspaces 0.2.5/THIRD_PARTY_OIR.txt'
    if oir.is_file():shutil.copy2(oir,out/oir.name)
    files={str(p.relative_to(out)).replace('\\','/'):sha(p) for p in (out/'src').rglob('*') if p.is_file()}
    for name in ('launch_app.py','Start Label Workflow.bat','Run Diagnostics.bat','README.txt','icon.ico','LICENSE','NOTICE','THIRD_PARTY_NOTICES.md','THIRD_PARTY_OIR.txt'):
        if (out/name).is_file():files[name]=sha(out/name)
    manifest={'version':'0.2.7','created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'runtime_source':'reused verified Windows runtime','runtime_executable_sha256':sha(out/'python/python.exe'),'dependencies_installed_or_changed':False,'source_files':files,'scientific_data_included':False,'cuda_required_for_instances':True}
    (out/'BUILD_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    archive=out.parent/(out.name+'-source.zip')
    if archive.exists():raise FileExistsError('Existing source archive preserved.')
    with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
        for name in files:z.write(out/name,name)
        z.write(out/'BUILD_MANIFEST.json','BUILD_MANIFEST.json')
        z.write(ROOT/'pyproject.toml','pyproject.toml')
    print(json.dumps({'build':str(out),'source_archive':str(archive),'manifest_sha256':sha(out/'BUILD_MANIFEST.json'),'source_archive_sha256':sha(archive),'source_files':len(files)}))

if __name__=='__main__':main()
