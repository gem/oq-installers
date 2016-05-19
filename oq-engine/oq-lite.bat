@echo off
setlocal
set mypath=%~dp0
set PYTHONPATH=pkgs
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set common="%COMMONPROGRAMFILES%"
) else (
    set common="%COMMONPROGRAMFILES(x86)%"
)

"%common%\Python\2.7\python.exe" openquake.commonlib.commands %*

endlocal
