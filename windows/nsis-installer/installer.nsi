!define /date MYTIMESTAMP "%y%m%d%H%M"
!define PRODUCT_NAME "OpenQuake Engine"
!define PRODUCT_VERSION "2.0.0-dev${MYTIMESTAMP}"
!define PUBLISHER "GEM Foundation"
!define BITNESS "32"
!define ARCH_TAG ""
!define INSTALLER_NAME "OpenQuake_Engine_${PRODUCT_VERSION}.exe"
!define PRODUCT_ICON "openquake.ico"
!include "FileFunc.nsh"
 
SetCompressor lzma

RequestExecutionLevel admin

; Modern UI installer stuff 
!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON "openquake_small.ico"

; UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${INSTALLER_NAME}"
InstallDir "$PROGRAMFILES${BITNESS}\${PRODUCT_NAME}"
ShowInstDetails show

Function .onInit
 
  ReadRegStr $R0 HKLM \
  "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
  "UninstallString"
  StrCmp $R0 "" done
 
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "${PRODUCT_NAME} is already installed. $\n$\nClick `OK` to remove the \
  previous version or `Cancel` to cancel this upgrade." \
  IDOK uninst
  Abort
 
;Run the uninstaller
uninst:
  ClearErrors
  Exec $INSTDIR\uninstall.exe
done:

FunctionEnd

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

; Section "Python ${PY_VERSION}" sec_py
; 
;   DetailPrint "Installing Python ${PY_MAJOR_VERSION}, ${BITNESS} bit"
;     File "msi\python-2.7.11.msi"
;     ExecWait 'msiexec /i "$INSTDIR\python-2.7.11.msi" \
;             /qb ALLUSERS=1 TARGETDIR="$COMMONFILES${BITNESS}\Python\${PY_MAJOR_VERSION}"'
;   Delete "$INSTDIR\python-2.7.11.msi"
; SectionEnd


Section "!${PRODUCT_NAME}" sec_app
  SectionIn RO
  SetShellVarContext all
  File ${PRODUCT_ICON}
  SetOutPath "$INSTDIR\python2.7"
  File /r "python2.7\*.*"
  SetOutPath "$INSTDIR\lib"
  File /r "lib\*.*"
  SetOutPath "$INSTDIR"
  
  ; Install files
    SetOutPath "$INSTDIR"
      File "LICENSE.txt"
      File "README.txt"
      File "openquake.cfg"
      File "openquake.ico"
      File "oq-server.bat"
      File "oq-console.bat"
  
  ; Install directories
    SetOutPath "$INSTDIR\demos"
    File /r "demos\*.*"
  
  ; Install shortcuts
  ; The output path becomes the working directory for shortcuts
  SetOutPath "$INSTDIR"
    CreateShortCut "$SMPROGRAMS\OpenQuake Engine (webui).lnk" "$INSTDIR\oq-server.bat" \
      "" "$INSTDIR\openquake.ico"
    CreateShortCut "$SMPROGRAMS\OpenQuake Engine (console).lnk" "$INSTDIR\oq-console.bat" \
      "" "$INSTDIR\openquake.ico"
  SetOutPath "$INSTDIR"
  
  ; Byte-compile Python files.
  DetailPrint "Byte-compiling Python modules..."
  nsExec::ExecToLog '$INSTDIR\python2.7\python.exe -m compileall -q "$INSTDIR\lib"'

  WriteUninstaller $INSTDIR\uninstall.exe
  ; Add ourselves to Add/remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "Publisher" "${PUBLISHER}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "DisplayVersion" "${PRODUCT_VERSION}"
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
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" \
                   "EstimatedSize" "$0"

  ; Check if we need to reboot
  IfRebootFlag 0 noreboot
    MessageBox MB_YESNO "A reboot is required to finish the installation. Do you wish to reboot now?" \
                /SD IDNO IDNO noreboot
      Reboot
  noreboot:
SectionEnd

Section "OpenQuake Engine desktop icon" sec_icon
  SetOutPath "$INSTDIR"
  CreateShortCut "$DESKTOP\OpenQuake Engine (webui).lnk" "$INSTDIR\oq-server.bat" \
      "" "$INSTDIR\openquake.ico"
  CreateShortCut "$DESKTOP\OpenQuake Engine (console).lnk" "$INSTDIR\oq-console.bat" \
      "" "$INSTDIR\openquake.ico"
SectionEnd

Section "Uninstall"
  SetShellVarContext all
  Delete $INSTDIR\uninstall.exe
  Delete "$INSTDIR\${PRODUCT_ICON}"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\python2.7"
  ; Uninstall files
    Delete "$INSTDIR\README.txt"
    Delete "$INSTDIR\LICENSE.txt"
    Delete "$INSTDIR\openquake.cfg"
    Delete "$INSTDIR\openquake.ico"
    Delete "$INSTDIR\oq-server.bat"
    Delete "$INSTDIR\oq-console.bat"
  ; Uninstall directories
    RMDir /r "$INSTDIR\demos"
  ; Uninstall shortcuts
    Delete "$DESKTOP\OpenQuake Engine (webui).lnk"
    Delete "$DESKTOP\OpenQuake Engine (console).lnk"
    Delete "$SMPROGRAMS\OpenQuake Engine (webui).lnk"
    Delete "$SMPROGRAMS\OpenQuake Engine (console).lnk"
  RMDir $INSTDIR
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
SectionEnd

; Functions

Function .onMouseOverSection
    ; Find which section the mouse is over, and set the corresponding description.
    FindWindow $R0 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R0 1043 ; description item (must be added to the UI)

;    StrCmp $0 ${sec_py} 0 +2
;      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The Python interpreter. \
;            This is required for ${PRODUCT_NAME} to run."

    StrCmp $0 ${sec_app} "" +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The ${PRODUCT_NAME} by GEM."
    
    StrCmp $0 ${sec_icon} "" +2
      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The OpenQuake Engine desktop icon."
FunctionEnd
