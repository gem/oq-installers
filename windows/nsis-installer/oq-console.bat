@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python2.7;%PATH%
set PYTHONPATH=%mypath%\lib\site-packages
set OQ_SITE_CFG_PATH=%mypath%\openquake.cfg

doskey pip=python.exe -m pip $*
doskey oq=python.exe -m openquake.commands.__main__ $*
doskey oq-engine=python.exe -m openquake.commands.__main__ engine $*

echo OpenQuake environment loaded
echo To run OpenQuake use 'oq' and 'oq engine'
cmd /k

endlocal
