:: cSpell:enableCompoundWords
setlocal

:: check the version before running!
set NINJA_VERSION=1.13.1

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set NINJA_ZIP=%DOWNLOADS_WIN%/ninja-%NINJA_VERSION%-win.zip
call utils\normalize_path %NINJA_ZIP%
set NINJA_ZIP_WIN=%retval%

set NINJA_EXE=%ROOTBIN%/ninja.exe
call utils\normalize_path %NINJA_EXE%
set NINJA_EXE_WIN=%retval%

set NINJA_VER_TMP=
if exist %NINJA_EXE_WIN% (for /F "tokens=*" %%g in ('%NINJA_EXE_WIN% --version') do (set NINJA_VER_TMP=%%g))
if not "%NINJA_VER_TMP%" == "%NINJA_VERSION%" (
  echo %YELLOWTEXT%Ninja version does not match.  Setting up Ninja.%DEFAULTTEXT%
  if not exist %NINJA_ZIP_WIN% (curl -o %NINJA_ZIP_WIN% -L https://github.com/ninja-build/ninja/releases/download/v%NINJA_VERSION%/ninja-win.zip || goto :curlfail)
  cd %ROOTBIN_WIN%
  tar -xmSf %NINJA_ZIP_WIN% || goto :tarfail
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
