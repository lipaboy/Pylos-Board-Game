import time, subprocess

from os import listdir, path
from os.path import isfile, join

compilerPath = 'C:\\Program Files (x86)\\PascalABC.NET\\pabcnetc.exe'

def compileTheFile(fileName: str):
    subprocess.run([compilerPath, fileName], shell = True)

buildDirs = [".//", ".//model", ".//view", ".//controller"]
for folder in buildDirs:
    if path.exists(folder):
        for f in listdir(folder):
            wholeFileName = join(folder, f)
            if isfile(wholeFileName) and f.endswith(".pas"):
                compileTheFile(wholeFileName)

# Воспроизведение звукового файла по завершении обратного отсчета