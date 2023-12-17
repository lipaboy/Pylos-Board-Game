import subprocess
import os
import shutil

compilerPath = 'C:\\Program Files (x86)\\PascalABC.NET\\pabcnetc.exe'

# traverse root directory, and list directories as dirs and files as files
for root, dirs, filesList in os.walk("src"):
    path = root.split(os.sep)
    # print((len(path) - 1) * '---', os.path.basename(root))
    # print(os.path.basename(root))
    for fname in filesList:
        if os.path.splitext(fname)[1] == '.pas':
            fullname = os.path.join(root, fname)
            shutil.copy2(fullname, './build/src_dump')

shutil.copytree('res', './build/res/', dirs_exist_ok=True)

def compileTheFile(fileName: str):
    subprocess.run([compilerPath, fileName, 'OutDir=./build/'], shell = True)

compileTheFile("./build/src_dump/main.pas")

shutil.move('./build/src_dump/main.exe', './build/PylosGame.exe')
shutil.move('./build/src_dump/main.pdb', './build/PylosGame.pdb')
