import subprocess
import os

output = subprocess.run(["py", "compile.py"])

if not output.returncode:
	os.chdir('./build')
	subprocess.run("./PylosGame.exe")