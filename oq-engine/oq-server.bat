@echo off
setlocal
set mypath=%~dp0
set PYTHONPATH=pkgs
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set common="%COMMONPROGRAMFILES%"
) else (
    set common="%COMMONPROGRAMFILES(x86)%"
)

REM Start the DbServer in background but within the same context
start "OpenQuake DB server" /B "%COMMONPROGRAMFILES%\Python\2.7\python.exe" -m openquake.server.dbserver

REM Make sure that the dbserver is up and running
echo Please wait ...
if exist C:\Windows\System32\timeout.exe (
    timeout /t 10 /nobreak > NUL
) else (
    REM Windows XP hack
    ping 192.0.2.2 -n 1 -w 10000 > nul 
)

REM Start the WebUI using django
"%common%\Python\2.7\python.exe" -m openquake.server.manage runserver %*

endlocal
