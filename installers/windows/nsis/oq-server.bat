@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python3.6;%mypath%\python3.6\Scripts;%PATH%
set OQ_HOST=localhost
set OQ_PORT=8800

if not exist python3.6\pycached (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul python3.6\pycached >nul
)

echo Starting the server.
echo Please wait ...
REM Start the WebUI using django
oq webui start %OQ_HOST%:%OQ_PORT%

endlocal
exit /b 0
