@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python2.7;%PATH%
set PYTHONPATH=%mypath%\lib\site-packages

doskey pip=python.exe -m pip $*
doskey oq=python.exe -m openquake.commands $*
doskey oq-engine=python.exe -m openquake.commands engine $*

echo OpenQuake environment loaded
echo To see versions of installed software run 'pip freeze'
echo To run OpenQuake use 'oq' and 'oq engine'
cmd /k

endlocal
