@echo off
setlocal
set mypath=%~dp0
set PATH=%PATH%;python2.7
set PYTHONPATH=pkgs

doskey oq-engine=python.exe -m openquake.engine.bin.openquake_cli %*
doskey oq-lite=python.exe -m openquake.commonlib.commands %*

echo OpenQuake environment loaded
cmd /k

endlocal
