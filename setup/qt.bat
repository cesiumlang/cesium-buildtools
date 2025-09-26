:: cSpell:enableCompoundWords
setlocal

:: check the version and target before running!
set QtVersion=6.8.0
set QtTarget=msvc2019_64
set Qt6_ROOT=C:/Qt/%QtVersion%/%QtTarget%/lib/cmake/Qt6
call utils\normalize_path %Qt6_ROOT%
set Qt6_ROOT_WIN=%retval%

:: https://doc.qt.io/qt-6/get-and-install-qt-cli.html#installing-without-user-interaction

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set QT_INSTALL_EXE=%DOWNLOADS_WIN%/qt-online-installer-windows-x64-online.exe
call utils\normalize_path %QT_INSTALL_EXE%
set QT_INSTALL_EXE_WIN=%retval%

set QT_VER_TMP=
:: next line needs work...
if exist %Qt6_ROOT_WIN% (for /F "tokens=*" %%g in ('%QT_INSTALL_EXE_WIN% --version') do (set QT_VER_TMP=%%g))
if not "%QT_VER_TMP%" == "%QtVersion%" (
  echo %YELLOWTEXT%Qt version does not match.  Setting up Qt.%DEFAULTTEXT%
  if not exist %QT_INSTALL_EXE_WIN% (curl -o %QT_INSTALL_EXE_WIN% -L https://download.qt.io/official_releases/online_installers/qt-online-installer-windows-x64-online.exe || goto :curlfail)
  cd %ROOTBUILD_WIN%
  @REM tar -xmSf %QT_INSTALL_EXE_WIN% || goto :tarfail
  cd %ROOT_WIN%
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
:success
cd %ROOT_WIN%
endlocal
