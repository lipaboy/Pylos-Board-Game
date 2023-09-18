import time, subprocess

from os import listdir, path
from os.path import isfile, join, isdir

compilerPath = 'C:\\Program Files (x86)\\PascalABC.NET\\pabcnetc.exe'

def compileTheFile(fileName: str):
    subprocess.run([compilerPath, fileName], shell = True)

buildDir = ".//src"
if path.exists(buildDir):
    dirsList = [buildDir]
    for folder in dirsList:
        for file in listdir(buildDir):
            wholeName = join(folder, file)
            if isfile(wholeName) and file.endswith(".pas"):
                compileTheFile(wholeName)
            elif isdir(wholeName):
                dirsList.append(wholeName)

# Воспроизведение звукового файла по завершении обратного отсчета