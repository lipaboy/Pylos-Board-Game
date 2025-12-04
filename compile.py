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
    result = subprocess.run([COMPILER_PATH, fileName, 'OutDir=./build/'], shell=True)
    print()
    print(f"Время сборки: {(time.time() - startTime):.1f} сек.")
    if result.returncode == 0:
        return True
    return False

if __name__ == "__main__":
    # TODO: удалять файлы из src_dump, которых уже нет в проекте

    if "-c" in sys.argv:
        shutil.rmtree("./build")

    if not os.path.isfile(COMPILER_PATH):
        print("Не существует такого файла:")
        print(COMPILER_PATH)
        sys.exit(1)

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

    if compileTheFile("./build/src_dump/main.pas"):
        shutil.move('./build/src_dump/main.exe', './build/PylosGame.exe')
        shutil.move('./build/src_dump/main.pdb', './build/PylosGame.pdb')
        sys.exit(0)
    else:
        print('Произошли ошибки во время компиляции.')
        sys.exit(1)
