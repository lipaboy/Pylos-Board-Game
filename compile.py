import time, subprocess

from os import listdir, path
from os.path import isfile, join, isdir

compilerPath = 'C:\\Program Files (x86)\\PascalABC.NET\\pabcnetc.exe'

def compileTheFile(fileName: str):
    subprocess.run([compilerPath, fileName], shell = True)

compileTheFile(".\\src\\main.pas")
# buildDir = ".\\src"
# if path.exists(buildDir):
#     dirsList = [buildDir]
#     for file in listdir(buildDir):
#         wholeName = join(buildDir, file)
#         if isfile(wholeName) and file.endswith(".pas"):
#             compileTheFile(wholeName)

# Воспроизведение звукового файла по завершении обратного отсчета