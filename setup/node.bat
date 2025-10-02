:: cSpell:enableCompoundWords
setlocal

@REM https://github.com/coreybutler/nvm-windows/releases/latest/download/nvm-setup.exe

:: check the version before running!
set NODE_VERSION=24.9.0

:: precompute paths and file names
set NODE_LONGNAME=node-v%NODE_VERSION%-win-x64
set NODE_NAME=node-%NODE_VERSION%

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set NODE_ZIP=%DOWNLOADS%/%NODE_NAME%.zip
call utils\normalize_path %NODE_ZIP%
set NODE_ZIP_WIN=%retval%

set NODE_DIR=%ROOTOPT%/%NODE_NAME%
call utils\normalize_path %NODE_DIR%
set NODE_DIR_WIN=%retval%

set NODE_EXE=%NODE_DIR%/node.exe
call utils\normalize_path %NODE_EXE%
set NODE_EXE_WIN=%retval%

set NODE_VER_TMP=
if exist %NODE_EXE_WIN% (for /F "tokens=3" %%g in ('%NODE_EXE_WIN% --version') do (
  set NODE_VER_TMP=%%g
  goto :checknode
))
:checknode
if not "%NODE_VER_TMP%" == "%NODE_VERSION%" (
  echo %YELLOWTEXT%Node version does not match.  Setting up Node.%DEFAULTTEXT%
  if not exist %NODE_ZIP_WIN% (curl -o %NODE_ZIP_WIN% -L https://nodejs.org/download/release/v%NODE_VERSION%/node-v%NODE_VERSION%-win-x64.zip || goto :curlfail)
  cd %ROOTOPT_WIN%
  if exist %NODE_DIR_WIN% (rmdir /S /Q %NODE_DIR_WIN%)
  echo tar extracting Node...
  tar -xmSf %NODE_ZIP_WIN% || goto :tarfail
  echo move tar
  move %NODE_LONGNAME% %NODE_NAME% || goto :movefail
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
endlocal & set PATH=%NODE_DIR_WIN%;%PATH%
