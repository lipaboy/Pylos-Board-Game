import subprocess
import os
import shutil
import sys
import time

# ----------------------------- #

def compileTheFile(fileName: str):
    startTime = time.time()
    result = subprocess.run([compilerPath, fileName, 'OutDir=./build/'], shell=True)
    print()
    print(f"Время сборки: {(time.time() - startTime):.1f} сек.")
    if result.returncode == 0:
        return True
    return False

if __name__ == "__main__":
    compilerPath = 'C:\\Apps\\PascalABC.NET\\pabcnetc.exe'

    if not os.path.isfile(compilerPath):
        print("Не существует такого файла:")
        print(compilerPath)
        sys.exit(1)

    if compileTheFile("./src/main.pas"):
        # shutil.move('./src/main.exe', './build/PylosGame.exe')
        # shutil.move('./src/main.pdb', './build/PylosGame.pdb')
        sys.exit(0)
    else:
        print('Произошли ошибки во время компиляции.')
        sys.exit(1)
