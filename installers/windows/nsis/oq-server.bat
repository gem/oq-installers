@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python3.5;%PATH%
set PYTHONPATH=%mypath%\lib\site-packages
set OQ_HOST=localhost
set OQ_PORT=8800

echo Please wait ...
REM Start the WebUI using django
python.exe -m openquake.commands webui start %OQ_HOST%:%OQ_PORT%

endlocal
exit /b 0
