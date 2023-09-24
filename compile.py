import subprocess

compilerPath = 'C:\\Program Files (x86)\\PascalABC.NET\\pabcnetc.exe'

def compileTheFile(fileName: str):
    subprocess.run([compilerPath, fileName], shell = True)

compileTheFile(".\\src\\main.pas")
