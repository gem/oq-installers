!define /date MYTIMESTAMP "%y%m%d%H%M"
!define PRODUCT_NAME "OpenQuake Engine"
!define VER_MAJOR "2"
!define VER_MINOR "2"
!define VER_REVISION "0"
!define VER_BUILD "${MYTIMESTAMP}"
!define PRODUCT_VERSION "${VER_MAJOR}.${VER_MINOR}.${VER_REVISION}.${VER_BUILD}"
!define PUBLISHER "GEM Foundation"
!define BITNESS "64"
!define ARCH_TAG ""
!define INSTALLER_NAME "OpenQuake_Engine_${VER_MAJOR}.${VER_MINOR}.${VER_REVISION}-${VER_BUILD}.exe"
!define PRODUCT_ICON "openquake.ico"
# WOW6432Node is needed because we are running 64bit software. It's hardcoded since we support only
# installations on 64bit systems (code is 64bit only)
!define REG_KEY "Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

!include "FileFunc.nsh"
!include "WordFunc.nsh"
!include "x64.nsh"

SetCompressor lzma

RequestExecutionLevel admin

; Modern UI installer stuff 
!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON "openquake_small.ico"

; UI pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!ifdef VER_MAJOR & VER_MINOR & VER_REVISION & VER_BUILD
Page custom PageReinstall PageLeaveReinstall
!endif
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

!ifdef VER_MAJOR & VER_MINOR & VER_REVISION & VER_BUILD
VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey "FileVersion" "${VER_MAJOR}.${VER_MINOR}.${VER_REVISION}"
VIAddVersionKey "FileDescription" "OpenQuake Setup"
VIAddVersionKey "LegalCopyright" "https://github.com/gem/oq-engine/blob/master/LICENSE"
!endif

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${INSTALLER_NAME}"
InstallDir "$PROGRAMFILES${BITNESS}\${PRODUCT_NAME}"

Function .onInit
  ${IfNot} ${RunningX64}
      MessageBox MB_OK "A 64bit OS is required"
      Quit
  ${EndIf}
FunctionEnd

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

Section "!Core Files" SecCore
  SectionIn RO
  SetShellVarContext all

  SetOutPath "$INSTDIR"
  File ${PRODUCT_ICON}
  File "LICENSE.txt"
  File "README.html"
  File "OpenQuake manual.pdf"
  File "oq-console.bat"

  SetOutPath "$INSTDIR"
    CreateShortCut "$SMPROGRAMS\OpenQuake Engine (webui).lnk" "$INSTDIR\oq-server.bat" \
      "" "$INSTDIR\openquake.ico"
  SetOutPath "$INSTDIR"

  SetOutPath "$INSTDIR\python2.7"
  File /r "python-dist\python2.7\*.*"

  SetOutPath "$INSTDIR\lib"
  File "checkifup.py"

  SetOutPath "$INSTDIR\lib\site-packages\openquake"
  File "src\__init__.py"
SectionEnd


Section "!Python libraries" SecLib
  SetShellVarContext all

  SetOutPath "$INSTDIR\lib"
  File /r /x "openquake*" "python-dist\lib\*.*"
SectionEnd


Section "!OpenQuake Engine and Hazardlib" SecOQ
  SetOutPath "$INSTDIR"
  File "oq-server.bat"
  SetOutPath "$INSTDIR\lib\site-packages"
  File /r "python-dist\lib\site-packages\openquake*.*"
  SetOutPath "$INSTDIR\demos"
  File /r /x ".gitignore" "demos\*.*"
  
  SetOutPath "$INSTDIR"
    CreateShortCut "$SMPROGRAMS\OpenQuake Engine (console).lnk" "$INSTDIR\oq-console.bat" \
      "" "$INSTDIR\openquake.ico"
  SetOutPath "$INSTDIR"

  !define OQ_INSTALLED "true"
SectionEnd

Section "OpenQuake Engine desktop icon" SecIcon
  SetOutPath "$INSTDIR"
  CreateShortCut "$DESKTOP\OpenQuake Engine (console).lnk" "$INSTDIR\oq-console.bat" \
      "" "$INSTDIR\openquake.ico"
  StrCmp "${OQ_INSTALLED}" "" done
  
  CreateShortCut "$DESKTOP\OpenQuake Engine (webui).lnk" "$INSTDIR\oq-server.bat" \
      "" "$INSTDIR\openquake.ico"
  done:
SectionEnd

Section -post
  ; Byte-compile Python files.
  DetailPrint "Byte-compiling Python modules..."
  nsExec::ExecToLog '$INSTDIR\python2.7\python.exe -m compileall -q "$INSTDIR\lib"'

  WriteUninstaller $INSTDIR\uninstall.exe

  ; Add ourselves to Add/remove programs
  WriteRegStr HKLM "${REG_KEY}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "${REG_KEY}" "Publisher" "${PUBLISHER}"
  WriteRegStr HKLM "${REG_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${REG_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "${REG_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${REG_KEY}" "DisplayIcon" "$INSTDIR\${PRODUCT_ICON}"
  WriteRegDWORD HKLM "${REG_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${REG_KEY}" "NoRepair" 1
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "${REG_KEY}" "EstimatedSize" "$0"

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
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\python2.7"
  ; Uninstall files
    Delete "$INSTDIR\README.html"
    Delete "$INSTDIR\LICENSE.txt"
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
  DeleteRegKey HKLM "${REG_KEY}"
SectionEnd


!ifdef VER_MAJOR & VER_MINOR & VER_REVISION & VER_BUILD

Var ReinstallPageCheck

Function PageReinstall

  ReadRegStr $R0 HKLM "Software\${PRODUCT_NAME}" ""
  ReadRegStr $R1 HKLM "${REG_KEY}" "UninstallString"
  ${IfThen} "$R0$R1" == "" ${|} Abort ${|}

  StrCpy $R4 "older"
  ReadRegDWORD $R0 HKLM "Software\${PRODUCT_NAME}" "VersionMajor"
  ReadRegDWORD $R1 HKLM "Software\${PRODUCT_NAME}" "VersionMinor"
  ReadRegDWORD $R2 HKLM "Software\${PRODUCT_NAME}" "VersionRevision"
  ReadRegDWORD $R3 HKLM "Software\${PRODUCT_NAME}" "VersionBuild"
  StrCpy $R0 $R0.$R1.$R2.$R3

  ${VersionCompare} ${VER_MAJOR}.${VER_MINOR}.${VER_REVISION}.${VER_BUILD} $R0 $R0
  ${If} $R0 == 0
    StrCpy $R1 "${PRODUCT_NAME} ${PRODUCT_VERSION} is already installed. Select the operation you want to perform and click Next to continue."
    StrCpy $R2 "Add/Reinstall components"
    StrCpy $R3 "Uninstall ${PRODUCT_NAME}"
    !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose the maintenance option to perform."
    StrCpy $R0 "2"
  ${ElseIf} $R0 == 1
    StrCpy $R1 "An $R4 version of ${PRODUCT_NAME} is installed on your system. It's recommended that you uninstall the current version before installing. Select the operation you want to perform and click Next to continue."
    StrCpy $R2 "Uninstall before installing"
    StrCpy $R3 "Upgrade/Repair"
    !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose how you want to install ${PRODUCT_NAME}."
    StrCpy $R0 "1"
  ${ElseIf} $R0 == 2
    StrCpy $R1 "A newer version of ${PRODUCT_NAME} is already installed! It is not recommended that you install an older version. If you really want to install this older version, it's better to uninstall the current version first. Select the operation you want to perform and click Next to continue."
    StrCpy $R2 "Uninstall before installing"
    StrCpy $R3 "Do not uninstall"
    !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose how you want to install ${PRODUCT_NAME}."
    StrCpy $R0 "1"
  ${Else}
    Abort
  ${EndIf}

  nsDialogs::Create 1018
  Pop $R4

  ${NSD_CreateLabel} 0 0 100% 24u $R1
  Pop $R1

  ${NSD_CreateRadioButton} 30u 50u -30u 8u $R2
  Pop $R2
  ${NSD_OnClick} $R2 PageReinstallUpdateSelection

  ${NSD_CreateRadioButton} 30u 70u -30u 8u $R3
  Pop $R3
  ${NSD_OnClick} $R3 PageReinstallUpdateSelection

  ${If} $ReinstallPageCheck != 2
    SendMessage $R2 ${BM_SETCHECK} ${BST_CHECKED} 0
  ${Else}
    SendMessage $R3 ${BM_SETCHECK} ${BST_CHECKED} 0
  ${EndIf}

  ${NSD_SetFocus} $R2

  nsDialogs::Show

FunctionEnd

Function PageReinstallUpdateSelection

  Pop $R1

  ${NSD_GetState} $R2 $R1

  ${If} $R1 == ${BST_CHECKED}
    StrCpy $ReinstallPageCheck 1
  ${Else}
    StrCpy $ReinstallPageCheck 2
  ${EndIf}

FunctionEnd

Function PageLeaveReinstall

  ${NSD_GetState} $R2 $R1

  StrCmp $R0 "1" 0 +2 ; Existing install is not the same version?
    StrCmp $R1 "1" reinst_uninstall reinst_done

  StrCmp $R1 "1" reinst_done ; Same version, skip to add/reinstall components?

  reinst_uninstall:
  ReadRegStr $R1 HKLM "${REG_KEY}" "UninstallString"

  ;Run uninstaller
    HideWindow

    ClearErrors
    ExecWait '$R1 _?=$INSTDIR' $0

    BringToFront

    ${IfThen} ${Errors} ${|} StrCpy $0 2 ${|} ; ExecWait failed, set fake exit code

  reinst_done:

FunctionEnd

!endif

#Function .onMouseOverSection
#    ; Find which section the mouse is over, and set the corresponding description.
#    FindWindow $R0 "#32770" "" $HWNDPARENT
#    GetDlgItem $R0 $R0 1043 ; description item (must be added to the UI)
#
#;    StrCmp $0 ${sec_py} 0 +2
#;      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The Python interpreter. \
#;            This is required for ${PRODUCT_NAME} to run."
#
#    StrCmp $0 ${sec_app} "" +2
#      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The ${PRODUCT_NAME} by GEM."
#    
#    StrCmp $0 ${sec_icon} "" +2
#      SendMessage $R0 ${WM_SETTEXT} 0 "STR:The OpenQuake Engine desktop icon."
#FunctionEnd
