@echo off
setlocal
set mypath=%~dp0
set PATH=%PATH%;%mypath%\python2.7
set PYTHONPATH=%mypath%\lib
set OQ_SITE_CFG_PATH=%mypath%

REM Create the DB or update it
python.exe -m openquake.server.db.upgrade_manager "%HOMEPATH%\db.sqlite3"

echo Please wait ...
REM Start the DbServer in background but within the same context
start "OpenQuake DB server" /B python.exe -m openquake.server.dbserver

REM Make sure that the dbserver is up and running
call:sleep 5

REM Start the WebUI using django
start "OpenQuake WebUI server" /B python.exe -m openquake.server.manage runserver %*

REM Make sure that the dbserver is up and running
call:sleep 2

REM Start the browser
start http://localhost:8000

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