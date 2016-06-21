@echo off
setlocal
set mypath=%~dp0
set PATH=%PATH%;%mypath%\python2.7
set PYTHONPATH=%mypath%\lib
set OQ_SITE_CFG_PATH=%mypath%\openquake.cfg

doskey oq=python.exe -m openquake.commands.__main__ $*
doskey oq-engine=python.exe -m openquake.commands.__main__ engine $*

echo OpenQuake environment loaded
echo The command 'oq-engine' is deprecated and will be removed. Please use 'oq engine' instead
cmd /k

endlocal
