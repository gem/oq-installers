@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python2.7;%PATH%
set PYTHONPATH=%mypath%\lib
set OQ_SITE_CFG_PATH=%mypath%\openquake.cfg
set OQ_HOST=localhost
set OQ_PORT=8800

echo Please wait ...
REM Start the WebUI using django
start "OpenQuake WebUI server" /B python.exe -m openquake.commands webui start %OQ_HOST%:%OQ_PORT%

REM Make sure that the dbserver is up and running
python lib\checkifup.py http://%OQ_HOST%:%OQ_PORT%

REM Start the browser
start http://%OQ_HOST%:%OQ_PORT%

endlocal
exit /b 0
