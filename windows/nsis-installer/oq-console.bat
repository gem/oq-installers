@echo off
setlocal
set mypath=%~dp0
set PATH=%PATH%;%mypath%\python2.7
set PYTHONPATH=%mypath%\lib
set OQ_SITE_CFG_PATH=%mypath%

doskey oq-engine=python.exe -m openquake.engine.bin.openquake_cli $*
doskey oq-lite=python.exe -m openquake.commonlib.commands $*

echo OpenQuake environment loaded
cmd /k

endlocal
