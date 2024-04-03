import subprocess
import os
import shutil
import sys

# TODO: удалять файлы из src_dump, которых уже нет в проекте

compilerPath = 'C:\\Program Files (x86)\\PascalABC.NET\\pabcnetc.exe'

os.makedirs('./build/src_dump', exist_ok=True)

# traverse root directory, and list directories as dirs and files as files
for root, dirs, filesList in os.walk("src"):
    path = root.split(os.sep)
    # print((len(path) - 1) * '---', os.path.basename(root))
    # print(os.path.basename(root))
    for fname in filesList:
        if os.path.splitext(fname)[1] == '.pas':
            fullname = os.path.join(root, fname)
            shutil.copy2(fullname, './build/src_dump/')

shutil.copytree('res', './build/res/', dirs_exist_ok=True)

def compileTheFile(fileName: str):
    result = subprocess.run([compilerPath, fileName, 'OutDir=./build/'], shell=True)
    if result.returncode == 0:
        return True
    return False

if compileTheFile("./build/src_dump/main.pas"):
    shutil.move('./build/src_dump/main.exe', './build/PylosGame.exe')
    shutil.move('./build/src_dump/main.pdb', './build/PylosGame.pdb')
    sys.exit(0)
else:
    print('Произошли ошибки во время компиляции.')
    sys.exit(1)
