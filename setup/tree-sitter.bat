:: cSpell:enableCompoundWords
setlocal

:: check the version and its checksum before running!
:: https://github.com/tree-sitter/tree-sitter/releases
set TREESITTER_VERSION=0.27.2
set TREESITTER_SHA256=9a6dc00c08ed26e98c05481f08c6f83c5ff05c6756442aec2aff1800732ad3da

:: precompute paths and file names
set TREESITTER_NAME=tree-sitter-%TREESITTER_VERSION%

:: Make sure to use forward slashes (/) for all path separators.
:: We will assume all paths are POSIX except those ending in `_WIN`.
set TREESITTER_ZIP=%DOWNLOADS%/%TREESITTER_NAME%.zip
call utils\normalize_path %TREESITTER_ZIP%
set TREESITTER_ZIP_WIN=%retval%

set TREESITTER_DIR=%ROOTOPT%/%TREESITTER_NAME%
call utils\normalize_path %TREESITTER_DIR%
set TREESITTER_DIR_WIN=%retval%

set TREESITTER_EXE=%TREESITTER_DIR%/tree-sitter.exe
call utils\normalize_path %TREESITTER_EXE%
set TREESITTER_EXE_WIN=%retval%

set TREESITTER_VER_TMP=
if exist %TREESITTER_EXE_WIN% (for /F "tokens=2" %%g in ('%TREESITTER_EXE_WIN% --version') do (
  set TREESITTER_VER_TMP=%%g
  goto :checktreesitter
))
:checktreesitter
if not "%TREESITTER_VER_TMP%" == "%TREESITTER_VERSION%" (
  echo %YELLOWTEXT%tree-sitter version does not match.  Setting up tree-sitter.%DEFAULTTEXT%
  if not exist %TREESITTER_ZIP_WIN% (curl -o %TREESITTER_ZIP_WIN% -L https://github.com/tree-sitter/tree-sitter/releases/download/v%TREESITTER_VERSION%/tree-sitter-cli-windows-x64.zip || goto :curlfail)
  call :checksum || goto :checksumfail
  if exist %TREESITTER_DIR_WIN% (rmdir /S /Q %TREESITTER_DIR_WIN%)
  mkdir %TREESITTER_DIR_WIN%
  echo tar extracting tree-sitter...
  tar -xmSf %TREESITTER_ZIP_WIN% -C %TREESITTER_DIR_WIN% || goto :tarfail
)
goto :success

:checksum
:: the second line of certutil's output is the hash
set TREESITTER_HASH=
for /F "skip=1 tokens=*" %%h in ('certutil -hashfile %TREESITTER_ZIP_WIN% SHA256') do (
  if not defined TREESITTER_HASH set TREESITTER_HASH=%%h
)
if /I "%TREESITTER_HASH: =%" == "%TREESITTER_SHA256%" exit /b 0
del %TREESITTER_ZIP_WIN%
exit /b 1

:curlfail
echo %REDTEXT%curl failure%DEFAULTTEXT%
exit /b 1
:tarfail
echo %REDTEXT%tar failure%DEFAULTTEXT%
exit /b 2
:checksumfail
echo %REDTEXT%checksum mismatch: the download was deleted%DEFAULTTEXT%
exit /b 5

:success
cd %ROOT_WIN%
endlocal & set PATH=%TREESITTER_DIR_WIN%;%PATH%
