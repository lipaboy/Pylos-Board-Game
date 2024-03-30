
Настольная игра в Пилос
=========
![image](https://github.com/lipatkin96/Pylos-Board-Game/assets/4948144/d541a94c-8371-4228-8348-ddfcafe151db)

Описание
--------
Игра рассчитана для двух игроков. Игроки ходят поочереди. У одного - светлые шары, у второго - тёмные. Окончанием игры является последний шарик на вершине пирамиды. Кто его положил последним, тот и победил в этой игре.

Сборка
--------
1. Для начала необходимо установить среду [PascalAbc.Net](https://pascalabc.net/ssyilki-dlya-skachivaniya) (выбрать <ins>Standard Pack</ins>).
2. В файле compile.py нужно задать путь до консольного компилятора *pabcnetc.exe* и присвоить путь переменной **compilerPath**:
```python
import subprocess
import os
import shutil

compilerPath = 'C:\\Program Files (x86)\\PascalABC.NET\\pabcnetc.exe'
```
3. Запустить скрипт **run.py**

