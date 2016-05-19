@echo off
setlocal
set mypath=%~dp0
set PYTHONPATH=pkgs
REM Start the DbServer in background but within the same context
start "OpenQuake DB server" /B "%COMMONPROGRAMFILES%\Python\2.7\python.exe" -m openquake.server.dbserver
REM Make sure that the dbserver is up and running
timeout /t 10 /nobreak > NUL
REM Start the WebUI using django
"%COMMONPROGRAMFILES%\Python\2.7\python.exe" -m openquake.server.manage runserver %*
endlocal
