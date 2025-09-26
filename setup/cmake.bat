:: cSpell:enableCompoundWords
setlocal

:: check the version before running!
set CMAKE_VERSION=4.1.1

:: precompute paths and file names
set CMAKE_LONGNAME=cmake-%CMAKE_VERSION%-windows-x86_64
set CMAKE_NAME=cmake-%CMAKE_VERSION%

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set CMAKE_ZIP=%DOWNLOADS_WIN%/%CMAKE_NAME%.zip
call utils\normalize_path %CMAKE_ZIP%
set CMAKE_ZIP_WIN=%retval%

set CMAKE_DIR=%ROOTBIN%/%CMAKE_NAME%
call utils\normalize_path %CMAKE_DIR%
set CMAKE_DIR_WIN=%retval%

set CMAKE_EXE=%CMAKE_DIR%/bin/cmake.exe
call utils\normalize_path %CMAKE_EXE%
set CMAKE_EXE_WIN=%retval%

set CMAKE_VER_TMP=
if exist %CMAKE_EXE_WIN% (for /F "tokens=3" %%g in ('%CMAKE_EXE_WIN% --version') do (
  set CMAKE_VER_TMP=%%g
  goto :checkcmake
))
:checkcmake
if not "%CMAKE_VER_TMP%" == "%CMAKE_VERSION%" (
  echo %YELLOWTEXT%CMake version does not match.  Setting up CMake.%DEFAULTTEXT%
  if not exist %CMAKE_ZIP_WIN% (curl -o %CMAKE_ZIP_WIN% -L https://github.com/Kitware/CMake/releases/download/v%CMAKE_VERSION%/cmake-%CMAKE_VERSION%-windows-x86_64.zip || goto :curlfail)
  cd %ROOTBIN_WIN%
  if exist %CMAKE_DIR_WIN% (rmdir /S /Q %CMAKE_DIR_WIN%)
  echo tar extracting Cmake...
  tar -xmSf %CMAKE_ZIP_WIN% || goto :tarfail
  echo move tar
  move %CMAKE_LONGNAME% %CMAKE_NAME% || goto :movefail
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
endlocal & set PATH=%CMAKE_DIR_WIN%\bin;%PATH%
