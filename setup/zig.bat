:: cSpell:enableCompoundWords
setlocal

:: check the version before running!
set ZIG_VERSION=0.15.1

:: precompute paths and file names
set ZIG_LONGNAME=zig-x86_64-windows-%ZIG_VERSION%
set ZIG_NAME=zig-%ZIG_VERSION%

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set ZIG_DIR=%ROOTOPT%/%ZIG_NAME%
call utils\normalize_path %ZIG_DIR%
set ZIG_DIR_WIN=%retval%

set ZIG_ZIP=%DOWNLOADS%/%ZIG_LONGNAME%.zip
call utils\normalize_path %ZIG_ZIP%
set ZIG_ZIP_WIN=%retval%

set ZIG_EXE=%ZIG_DIR%/zig.exe
call utils\normalize_path %ZIG_EXE%
set ZIG_EXE_WIN=%retval%

set ZIG_VER_TMP=
if exist %ZIG_EXE_WIN% (for /F "tokens=*" %%g in ('%ZIG_EXE_WIN% version') do (
  set ZIG_VER_TMP=%%g
  goto :checkzig
))
:checkzig
if not "%ZIG_VER_TMP%" == "%ZIG_VERSION%" (
  echo %YELLOWTEXT%Zig version does not match.  Setting up Zig.%DEFAULTTEXT%
  if not exist %ZIG_ZIP_WIN% (curl -o %ZIG_ZIP_WIN% -L https://ziglang.org/download/%ZIG_VERSION%/zig-x86_64-windows-%ZIG_VERSION%.zip || goto :curlfail)
  if exist %ZIG_DIR_WIN% (rmdir /S /Q %ZIG_DIR_WIN%)
  cd %ROOTOPT_WIN%
  echo tar extracting Zig...
  tar -xmSf %ZIG_ZIP_WIN% || goto :tarfail
  echo move tar
  move %ZIG_LONGNAME% %ZIG_NAME% || goto :movefail
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
endlocal & set PATH=%ZIG_DIR_WIN%;%PATH%
