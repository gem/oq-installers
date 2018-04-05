@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\bin;%mypath%\python3.5;%PATH%
set PYTHONPATH=%mypath%\lib\site-packages

doskey pip=python.exe -m pip $*

if not exist lib\pycache (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul lib\pycache >nul
)

echo OpenQuake environment loaded
echo To see versions of installed software run 'pip freeze'
echo To run OpenQuake use 'oq' and 'oq engine'
cmd /k

endlocal