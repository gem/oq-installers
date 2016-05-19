!define PRODUCT_NAME "OpenQuake Engine"
!define PRODUCT_VERSION "2.0.0"
!define /date MYTIMESTAMP "%y%m%d%H%M"
!define PY_VERSION "2.7.11"
!define PY_MAJOR_VERSION "2.7"
!define BITNESS "32"
!define ARCH_TAG ""
!define INSTALLER_NAME "OpenQuake_Engine_2.0.0-${MYTIMESTAMP}.exe"
!define PRODUCT_ICON "openquake.ico"
 
SetCompressor lzma

RequestExecutionLevel admin

; Modern UI installer stuff 
!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON "openquake_small.ico"

; UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${INSTALLER_NAME}"
InstallDir "$PROGRAMFILES${BITNESS}\${PRODUCT_NAME}"
ShowInstDetails show

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

Section "PyLauncher" sec_pylauncher
    ; Check for the existence of the pyw command, skip installing if it exists
    nsExec::Exec 'where pyw'
    Pop $0
    IntCmp $0 0 SkipPylauncher
    ; Extract the py/pyw launcher msi and run it.
    File "msi\launchwin${ARCH_TAG}.msi"
    ExecWait 'msiexec /i "$INSTDIR\launchwin${ARCH_TAG}.msi" /qb ALLUSERS=1'
    Delete "$INSTDIR\launchwin${ARCH_TAG}.msi"
    SkipPylauncher:
SectionEnd

Section "Python ${PY_VERSION}" sec_py

  DetailPrint "Installing Python ${PY_MAJOR_VERSION}, ${BITNESS} bit"
    File "msi\python-2.7.11.msi"
    ExecWait 'msiexec /i "$INSTDIR\python-2.7.11.msi" \
            /qb ALLUSERS=1 TARGETDIR="$COMMONFILES${BITNESS}\Python\${PY_MAJOR_VERSION}"'
  Delete "$INSTDIR\python-2.7.11.msi"
SectionEnd


Section "!${PRODUCT_NAME}" sec_app
  SectionIn RO
  SetShellVarContext all
  File ${PRODUCT_ICON}
  SetOutPath "$INSTDIR\pkgs"
  File /r "pkgs\*.*"
  SetOutPath "$INSTDIR"
  
  ; Install files
    SetOutPath "$INSTDIR"
      File "oq-engine.bat"
      File "openquake.ico"
      File "oq-engine.bat"
      File "oq-lite.bat"
      File "oq-server.bat"
      File "oq-console.bat"
  
  ; Install directories
    SetOutPath "$INSTDIR\demos"
    File /r "demos\*.*"
  
  ; Install shortcuts
  ; The output path becomes the working directory for shortcuts
  SetOutPath "$INSTDIR"
    CreateShortCut "$SMPROGRAMS\OpenQuake Engine.lnk" "$INSTDIR\oq-server.bat" \
      "" "$INSTDIR\openquake.ico"
  SetOutPath "$INSTDIR"
  
  ; Byte-compile Python files.
  DetailPrint "Byte-compiling Python modules..."
  nsExec::ExecToLog 'py -2.7-32 -m compileall -q "$INSTDIR\pkgs"'
  WriteUninstaller $INSTDIR\uninstall.exe
  ; Add ourselves to Add/remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayIcon" "$INSTDIR\${PRODUCT_ICON}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "NoRepair" 1

  ; Check if we need to reboot
  IfRebootFlag 0 noreboot
    MessageBox MB_YESNO "A reboot is required to finish the installation. Do you wish to reboot now?" \
                /SD IDNO IDNO noreboot
      Reboot
  noreboot:
SectionEnd

Section "Uninstall"
  SetShellVarContext all
  Delete $INSTDIR\uninstall.exe
  Delete "$INSTDIR\${PRODUCT_ICON}"
  RMDir /r "$INSTDIR\pkgs"
  ; Uninstall files
    Delete "$INSTDIR\oq-engine.bat"
    Delete "$INSTDIR\openquake.ico"
    Delete "$INSTDIR\oq-engine.bat"
    Delete "$INSTDIR\oq-lite.bat"
    Delete "$INSTDIR\oq-server.bat"
    Delete "$INSTDIR\oq-console.bat"
  ; Uninstall directories
    RMDir /r "$INSTDIR\demos"
  ; Uninstall shortcuts
      Delete "$SMPROGRAMS\OpenQuake Engine.lnk"
  RMDir $INSTDIR
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
SectionEnd




; Functions

Function .onMouseOverSection
    ; Find which section the mouse is over, and set the corresponding description.
    FindWindow $R0 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R0 1043 ; description item (must be added to the UI)

    StrCmp $0 ${sec_py} 0 +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The Python interpreter. \
            This is required for ${PRODUCT_NAME} to run."

    StrCmp $0 ${sec_app} "" +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:${PRODUCT_NAME}"
    


    StrCmp $0 ${sec_app} "" +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The Python launcher. \
          This is required for ${PRODUCT_NAME} to run."
FunctionEnd
