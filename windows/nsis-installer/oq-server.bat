@echo off
setlocal
set mypath=%~dp0
set PATH=%mypath%\python2.7;%PATH%
set PYTHONPATH=%mypath%\lib
set OQ_SITE_CFG_PATH=%mypath%\openquake.cfg
set OQ_HOST=127.0.0.1
set OQ_PORT=8800

echo Please wait ...
REM Start the DbServer in background but within the same context
start "OpenQuake DB server" /B python.exe -m openquake.server.dbserver

REM Make sure that the dbserver is up and running
call:sleep 5

REM Start the WebUI using django
start "OpenQuake WebUI server" /B python.exe -m openquake.server.manage runserver %OQ_HOST%:%OQ_PORT%

REM Make sure that the dbserver is up and running
call:sleep 2

REM Start the browser
start http://localhost:%OQ_PORT%

endlocal
exit /b 0

:sleep 
setlocal
if exist C:\Windows\System32\timeout.exe (
    timeout /t %~1 /nobreak > NUL
) else (
    REM Windows XP hack
    ping 192.0.2.2 -n %~1 -w 1000 > NUL 
)
endlocal
