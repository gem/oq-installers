@echo off
setlocal
set mypath=%~dp0
set PYTHONPATH=pkgs
start "OpenQuake DB server" /B "%COMMONPROGRAMFILES%\Python\2.7\python.exe" -m openquake.server.dbserver
"%COMMONPROGRAMFILES%\Python\2.7\python.exe" -m openquake.server.manage runserver %*
endlocal
