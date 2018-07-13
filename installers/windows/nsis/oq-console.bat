@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python3.6;%mypath%\python3.6\Scripts;%PATH%

if not exist python3.6\pycached (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul python3.6\pycached >nul
)

echo OpenQuake environment loaded
echo To see versions of installed software run 'pip freeze'
echo To run OpenQuake use 'oq' and 'oq engine'
cmd /k

endlocal
