import subprocess
import os

subprocess.run(["py", "compile.py"], shell = True)
os.chdir('./build')
subprocess.run("./PylosGame.exe")

# Воспроизведение звукового файла по завершении обратного отсчета