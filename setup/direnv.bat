:: cSpell:enableCompoundWords
setlocal

:: check the version and its checksum before running!
:: https://github.com/direnv/direnv/releases (no checksum file is published;
:: the sha256 is the digest GitHub lists for the release asset)
set DIRENV_VERSION=2.38.2
set DIRENV_SHA256=62a6a16a3473b8e03c2cdc4e2099655bd4284f6da92122b96d78cdce724d4064

:: precompute paths and file names
set DIRENV_NAME=direnv-%DIRENV_VERSION%

:: Make sure to use forward slashes (/) for all path separators.
:: We will assume all paths are POSIX except those ending in `_WIN`.
set DIRENV_DOWNLOAD=%DOWNLOADS%/%DIRENV_NAME%.exe
call utils\normalize_path %DIRENV_DOWNLOAD%
set DIRENV_DOWNLOAD_WIN=%retval%

set DIRENV_DIR=%ROOTOPT%/%DIRENV_NAME%
call utils\normalize_path %DIRENV_DIR%
set DIRENV_DIR_WIN=%retval%

set DIRENV_EXE=%DIRENV_DIR%/direnv.exe
call utils\normalize_path %DIRENV_EXE%
set DIRENV_EXE_WIN=%retval%

set DIRENV_VER_TMP=
if exist %DIRENV_EXE_WIN% (for /F "tokens=*" %%g in ('%DIRENV_EXE_WIN% version') do (
  set DIRENV_VER_TMP=%%g
  goto :checkdirenv
))
:checkdirenv
if not "%DIRENV_VER_TMP%" == "%DIRENV_VERSION%" (
  echo %YELLOWTEXT%direnv version does not match.  Setting up direnv.%DEFAULTTEXT%
  if not exist %DIRENV_DOWNLOAD_WIN% (curl -o %DIRENV_DOWNLOAD_WIN% -L https://github.com/direnv/direnv/releases/download/v%DIRENV_VERSION%/direnv.windows-amd64.exe || goto :curlfail)
  call :checksum || goto :checksumfail
  if exist %DIRENV_DIR_WIN% (rmdir /S /Q %DIRENV_DIR_WIN%)
  mkdir %DIRENV_DIR_WIN%
  copy /Y %DIRENV_DOWNLOAD_WIN% %DIRENV_EXE_WIN% || goto :copyfail
)
goto :success

:checksum
:: the second line of certutil's output is the hash
set DIRENV_HASH=
for /F "skip=1 tokens=*" %%h in ('certutil -hashfile %DIRENV_DOWNLOAD_WIN% SHA256') do (
  if not defined DIRENV_HASH set DIRENV_HASH=%%h
)
if /I "%DIRENV_HASH: =%" == "%DIRENV_SHA256%" exit /b 0
del %DIRENV_DOWNLOAD_WIN%
exit /b 1

:curlfail
echo %REDTEXT%curl failure%DEFAULTTEXT%
exit /b 1
:copyfail
echo %REDTEXT%copy failure%DEFAULTTEXT%
exit /b 3
:checksumfail
echo %REDTEXT%checksum mismatch: the download was deleted%DEFAULTTEXT%
exit /b 5

:success
cd %ROOT_WIN%
endlocal & set PATH=%DIRENV_DIR_WIN%;%PATH%
