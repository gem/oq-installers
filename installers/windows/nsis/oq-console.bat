@echo off
setlocal
set mypath=C:\Program Files\OpenQuake Engine
set PATH=%mypath%\python;%mypath%\python\Scripts;%PATH%

if not exist python\pycached (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul python\pycached >nul
)

echo OpenQuake environment loaded
echo To see versions of installed software run 'python -m pip freeze'
echo To run OpenQuake use 'oq' and 'oq engine'
cmd /k

endlocal
