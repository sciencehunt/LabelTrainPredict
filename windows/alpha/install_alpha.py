"""Portable alpha installer. No administrator rights or policy changes required."""
import argparse,hashlib,json,os,shutil,subprocess,sys,tempfile,urllib.request,zipfile
from pathlib import Path

TAG='v0.2.12-alpha.1'
NAME='LTP Windows 0.2.12 alpha.1'

def sha(path):
    digest=hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda:stream.read(8*1024*1024),b''):digest.update(block)
    return digest.hexdigest()

def install(destination, no_shortcut=False):
    here=Path(__file__).resolve().parent
    manifest=json.loads((here/'download-manifest.json').read_text())
    assert manifest['tag']==TAG, 'Unexpected release manifest'
    destination=Path(destination).absolute()
    assert destination.parent!=destination, 'Choose an application subfolder'
    assert not destination.exists(), 'Destination already exists. Choose a new folder; existing installations are never replaced.'
    for parent in [destination.parent,*destination.parents]:
        assert not parent.is_symlink() and not parent.is_junction(), 'Linked installation directories are not supported'
    destination.parent.mkdir(parents=True,exist_ok=True)
    assert shutil.disk_usage(destination.parent).free>=30*1024**3, 'Allow 30 GB free disk space for installation'
    import re
    parts=manifest['parts']
    assert [p['name'] for p in parts]==[f'LTP-windows-x64-app.part{i+1}' for i in range(len(parts))], 'Invalid part order'
    assert parts and all(re.fullmatch('[a-f0-9]{64}',p['sha256']) for p in parts), 'Invalid checksums'
    for part in parts:
        target=here/part['name']
        if not target.exists():
            print('Downloading',part['name'],'...',flush=True)
            handle,partial=tempfile.mkstemp(prefix=part['name']+'.',suffix='.partial',dir=here)
            with os.fdopen(handle,'wb') as output:
                with urllib.request.urlopen(f'https://github.com/sciencehunt/LabelTrainPredict/releases/download/{TAG}/{part["name"]}',timeout=120) as response:
                    shutil.copyfileobj(response,output,8*1024*1024)
            partial=Path(partial)
            assert partial.stat().st_size==part['bytes'] and sha(partial)==part['sha256'], 'Downloaded file failed verification'
            partial.rename(target)
        assert target.stat().st_size==part['bytes'] and sha(target)==part['sha256'], f'Checksum mismatch: {part["name"]}'
    print('Joining and verifying the application...',flush=True)
    handle,archive=tempfile.mkstemp(prefix='ltp-alpha-',suffix='.zip',dir=here)
    with os.fdopen(handle,'wb') as output:
        for part in parts:
            with (here/part['name']).open('rb') as source:shutil.copyfileobj(source,output,8*1024*1024)
    archive=Path(archive)
    assert sha(archive)==manifest['archive_sha256'], 'Archive verification failed'
    with zipfile.ZipFile(archive) as package:
        for entry in package.infolist():
            assert (destination/entry.filename).resolve().is_relative_to(destination.resolve()), 'Unsafe archive member'
        print('Extracting the app and GPU runtimes...',flush=True)
        destination.mkdir()
        package.extractall(destination)
    python=destination/'python/python.exe'
    subprocess.run([str(python),'-B',str(destination/'verify_runtime.py')],check=True)
    if not no_shortcut:
        # Ask Windows for the actual redirected Desktop path; do not assume ~/Desktop.
        import ctypes
        buffer=ctypes.create_unicode_buffer(32768)
        code=ctypes.windll.shell32.SHGetFolderPathW(None,0x10,None,0,buffer)
        if code==0:
            desktop=Path(buffer.value)
            shortcut=desktop/(NAME+'.cmd')
            if not shortcut.exists():
                shortcut.write_text('@echo off\r\n"'+str(destination/'python/pythonw.exe')+'" -B "'+str(destination/'launch_ltp.py')+'"\r\n',encoding='utf-8')
    print(f'Installed to {destination}. Open Launch LTP.cmd.',flush=True)
    print('Downloaded parts and the joined archive were retained; you can delete them after testing.',flush=True)

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--destination',default=str(Path(os.environ.get('LOCALAPPDATA',Path.home()))/'Programs'/NAME))
    parser.add_argument('--no-shortcut',action='store_true')
    args=parser.parse_args()
    try:install(args.destination,args.no_shortcut)
    except Exception as error:
        print('Installation did not complete:',error,flush=True)
        print('Keep Windows protection enabled and report the exact error to the LTP GitHub Issues page.',flush=True)
        sys.exit(1)
