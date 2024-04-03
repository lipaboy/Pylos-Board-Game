import subprocess
import os
import shutil
import sys

# TODO: удалять файлы из src_dump, которых уже нет в проекте

shutil.rmtree('./build/src_dump')
output = subprocess.run(["py", "compile.py"])
