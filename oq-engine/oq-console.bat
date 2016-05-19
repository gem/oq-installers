@echo off
setlocal
set mypath=%~dp0
if "%PROCESSOR_ARCHITECTURE%"=="x86"
    set common=%COMMONPROGRAMFILES%
else
    set common=%COMMONPROGRAMFILES(x86)%)
set PATH=%PATH%;%common%\Python\2.7
set PYTHONPATH=pkgs

cmd /k

endlocal
