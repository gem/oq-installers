@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\bin;%mypath%\python3.5;%PATH%
set PYTHONPATH=%mypath%\lib\site-packages
set OQ_HOST=localhost
set OQ_PORT=8800

if not exist lib\pycache (
   echo Building python cache. This may take a while.
   echo Please wait ...
   python.exe -m compileall -qq .
   copy /y nul lib\pycache >nul
)

echo Starting the server.
echo Please wait ...
REM Start the WebUI using django
oq webui start %OQ_HOST%:%OQ_PORT%

endlocal
exit /b 0
