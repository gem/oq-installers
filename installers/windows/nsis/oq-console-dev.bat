@echo off
setlocal
IF NOT EXIST oq-engine GOTO MISSINGDIR:

set mypath=%~dp0
set PATH=%mypath%\python2.7;%PATH%
set PYTHONPATH=%mypath%\oq-engine;%mypath%\lib\site-packages

doskey pip=python.exe -m pip $*
doskey oq=python.exe -m openquake.commands $*
doskey oq-engine=python.exe -m openquake.commands engine $*

echo OpenQuake environment loaded
echo To see versions of installed software run 'pip freeze'
echo To run OpenQuake use 'oq' and 'oq engine'
cmd /k

:MISSINGDIR
echo You must clone the oq-engine repo inside this folder first:
echo.
echo git clone https://github.com/gem/oq-engine.git
echo.
pause

endlocal
