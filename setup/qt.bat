:: cSpell:enableCompoundWords
setlocal

:: check the version and target before running!
set QtVersion=6.8.0
set QtTarget=msvc2022_64
@REM set QtTarget=msvc2019_64
@REM set Qt6_ROOT=C:/Qt/%QtVersion%/%QtTarget%/lib/cmake/Qt6
@REM call utils\normalize_path %Qt6_ROOT%
@REM set Qt6_ROOT_WIN=%retval%

:: precompute paths and file names
set QtVersionCompact=%QtVersion:.=%
set QT_LONGNAME=qt.qt6.%QtVersionCompact%.win64_%QtTarget%
set QT_NAME=qt-%QtVersion%

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set QT_INSTALL_EXE=%DOWNLOADS%/qt-online-installer-windows-x64-online.exe
call utils\normalize_path %QT_INSTALL_EXE%
set QT_INSTALL_EXE_WIN=%retval%

set Qt6_ROOT=%ROOTOPT%/%QT_NAME%
call utils\normalize_path %Qt6_ROOT%
set Qt6_ROOT_WIN=%retval%

set QT_MAINT_EXE=%Qt6_ROOT%/MaintenanceTool.exe
call utils\normalize_path %QT_MAINT_EXE%
set QT_MAINT_EXE_WIN=%retval%

set QT_AUTH=%APPDATA%\Qt\qtaccount.ini
set QTEMAILFILE=%ROOT_WIN%\.qtemail
set QTPASSFILE=%ROOT_WIN%\.qtpassword

@REM :: test if admin
@REM set COPYONLY=
@REM if %ADMIN_PRIV%==1 (set COPYONLY=copy_only=1)

set QT_ARGS=--root %Qt6_ROOT_WIN% --accept-obligations --accept-licenses --default-answer --confirm-command install %QT_LONGNAME%

set QT_VER_TMP=
if exist %QT_MAINT_EXE_WIN% (
  setlocal EnableDelayedExpansion
  for /F "tokens=*" %%v in ('%QT_MAINT_EXE_WIN% list ^| findstr /C:"%QT_LONGNAME%"') do (
    for /F "tokens=1 delims=/" %%a in ("%%v") do set "QT_VER_TMP2=%%a"
    set "QT_VER_TMP2=!QT_VER_TMP2:* version=!"
    for /F "tokens=1 delims==" %%a in ("!QT_VER_TMP2!") do set "QT_VER_TMP2=%%a"
    set "QT_VER_TMP2=!QT_VER_TMP2:"=!"
    for /F "tokens=1 delims=-" %%a in ("!QT_VER_TMP2!") do set "QT_VER_TMP2=%%a"
    for /F %%x in ("!QT_VER_TMP2!") do (endlocal & set "QT_VER_TMP=%%x")
    goto :checkqt
  )
  :: only gets here if the version not found in first for
  endlocal
)
:checkqt
if not "%QT_VER_TMP%" == "%QtVersion%" (
  echo %YELLOWTEXT%Qt version does not match.  Setting up Qt.%DEFAULTTEXT%
  if not exist %QT_INSTALL_EXE_WIN% (curl -o %QT_INSTALL_EXE_WIN% -L https://download.qt.io/official_releases/online_installers/qt-online-installer-windows-x64-online.exe || goto :curlfail)
  if exist %Qt6_ROOT_WIN% (rmdir /S /Q %Qt6_ROOT_WIN%)
  cd %ROOTOPT_WIN%
  :: https://doc.qt.io/qt-6/get-and-install-qt-cli.html#installing-without-user-interaction
  if exist %QT_AUTH% (%QT_INSTALL_EXE_WIN% %QT_ARGS% || goto :installfail) else (
    setlocal EnableDelayedExpansion
      call :qt_login
      @REM echo --email !QTUSER! --pw !QTPASS!
      %QT_INSTALL_EXE_WIN% --email !QTUSER! --pw !QTPASS! %QT_ARGS% || goto :installfail
    endlocal
  )
)
goto :success

:curlfail
echo %REDTEXT%curl failure%DEFAULTTEXT%
exit /b 1
:tarfail
echo %REDTEXT%tar failure%DEFAULTTEXT%
exit /b 2
:movefail
echo %REDTEXT%move failure%DEFAULTTEXT%
exit /b 3
:installfail
echo %REDTEXT%install failure%DEFAULTTEXT%
exit /b 4

:qt_login
if exist %QTEMAILFILE% (set /p QTUSER=<%QTEMAILFILE%) else set /p QTUSER="Enter Qt username email: "
if exist %QTPASSFILE% (set /p QTPASS=<%QTPASSFILE%) else (
  for /f "delims=" %%A in ('..\utils\input.bat "prompt=Enter Qt password: " "symbol=*"') do (
    set "QTPASS=%%A"
  )
)
exit /b

:success
cd %ROOT_WIN%
endlocal & set PATH=%Qt6_ROOT_WIN%\bin;%PATH%
