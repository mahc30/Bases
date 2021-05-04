import os

folders = []

for folderName, subfolders, filenames in os.walk("D:\DasSache\Bases\Red de Escuelas de Música\REPERTORIO ESCUELA SANTA FE"):
    folders.append(folderName)
    
print(str(folders))
