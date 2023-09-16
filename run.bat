for %%f in ("%1\*.pas") do "%pabcnetc%" "%%f"
for %%f in ("%1\model\*.pas") do "%pabcnetc%" "%%f"
%1\main.exe
