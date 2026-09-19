import subprocess
import os
import shutil
import sys
import time

# -------------------------------------- #

COMPILER_PATH = 'C:\\Apps\\PascalABC.NET\\pabcnetc.exe'

# -------------------------------------- #

def compileTheFile(fileName: str):
    startTime = time.time()
    result = subprocess.run([COMPILER_PATH, fileName, 'OutDir=./build/ Debug=0'], shell=True)
    print()
    print(f"Время сборки: {(time.time() - startTime):.1f} сек.")
    if result.returncode == 0:
        return True
    return False

if __name__ == "__main__":
    # TODO: удалять файлы из src_dump, которых уже нет в проекте
    # по идее надо просто удалить всю папку перед этим

    if "-c" in sys.argv:
        shutil.rmtree("./build")

    if not os.path.isfile(COMPILER_PATH):
        print("Не существует такого файла:")
        print(COMPILER_PATH)
        sys.exit(1)

    shutil.copytree('src', './build/src/', dirs_exist_ok=True)
    shutil.copytree('res', './build/res/', dirs_exist_ok=True)

    if compileTheFile("./build/src/main.pas"):
        shutil.move('./build/src/main.exe', './build/PylosGame.exe')
        shutil.move('./build/src/main.pdb', './build/PylosGame.pdb')
        sys.exit(0)
    else:
        print('Произошли ошибки во время компиляции.')
        sys.exit(1)
