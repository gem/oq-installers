@echo off
setlocal
set mypath=%~dp0
set PATH=%PATH%;%mypath%\python2.7
set PYTHONPATH=%mypath%\lib
set OQ_SITE_CFG_PATH=%mypath%

doskey oq=python.exe -m openquake.commands.__main__ $*
doskey oq-engine=python.exe -m openquake.commonlib.commands engine $*

echo OpenQuake environment loaded
cmd /k

endlocal
