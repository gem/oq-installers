@echo off
setlocal
set mypath=%~dp0
set PYTHONPATH=lib
set PATH=%PATH%;%mypath%\python2.7

REM Create the DB or update it
python.exe -m openquake.server.db.upgrade_manager "%HOMEPATH%\db.sqlite3"

REM Start the DbServer in background but within the same context
start "OpenQuake DB server" /B python.exe -m openquake.server.dbserver

REM Make sure that the dbserver is up and running
echo Please wait ...
if exist C:\Windows\System32\timeout.exe (
    timeout /t 10 /nobreak > NUL
) else (
    REM Windows XP hack
    ping 192.0.2.2 -n 1 -w 10000 > NUL 
)

REM Start the WebUI using django
python.exe -m openquake.server.manage runserver %*

endlocal
