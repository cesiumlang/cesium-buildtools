:: cSpell:enableCompoundWords
@echo off
setlocal
call utils\console_colors.bat

set INCLUDE_CMAKE=1
set INCLUDE_LLVM=1
set INCLUDE_NINJA=1
set INCLUDE_ZIG=1
set INCLUDE_QT=1
set INCLUDE_VULKAN=1
set INCLUDE_MINIFORGE=0
set INCLUDE_GIT=1
set INCLUDE_NODE=1

set FORCE_MINIFORGE=0
set FORCE_GIT=0
set EXPORT_PATH=0
set ECHO_PATH=0
set LASTARG=
:loop
if not "%~1"=="" (
  if "%1"=="--export-path" (
    set EXPORT_PATH=1
  ) else if "%1"=="--echo-path" (
    set ECHO_PATH=1
  ) else if "%1"=="--cmake" (
    set INCLUDE_CMAKE=1
  ) else if "%1"=="--no-cmake" (
    set INCLUDE_CMAKE=0
  ) else if "%1"=="--llvm" (
    set INCLUDE_LLVM=1
  ) else if "%1"=="--no-llvm" (
    set INCLUDE_LLVM=0
  ) else if "%1"=="--ninja" (
    set INCLUDE_NINJA=1
  ) else if "%1"=="--no-ninja" (
    set INCLUDE_NINJA=0
  ) else if "%1"=="--zig" (
    set INCLUDE_ZIG=1
  ) else if "%1"=="--no-zig" (
    set INCLUDE_ZIG=0
  ) else if "%1"=="--qt" (
    set INCLUDE_QT=1
  ) else if "%1"=="--no-qt" (
    set INCLUDE_QT=0
  ) else if "%1"=="--vulkan" (
    set INCLUDE_VULKAN=1
  ) else if "%1"=="--no-vulkan" (
    set INCLUDE_VULKAN=0
  ) else if "%1"=="--miniforge" (
    set INCLUDE_MINIFORGE=1
  ) else if "%1"=="--no-miniforge" (
    set INCLUDE_MINIFORGE=0
  ) else if "%1"=="--force-miniforge" (
    set INCLUDE_MINIFORGE=1
    set FORCE_MINIFORGE=1
  ) else if "%1"=="--git" (
    set INCLUDE_GIT=1
  ) else if "%1"=="--no-git" (
    set INCLUDE_GIT=0
  ) else if "%1"=="--force-git" (
    set INCLUDE_GIT=1
    set FORCE_GIT=1
  ) else if "%1"=="--node" (
    set INCLUDE_NODE=1
  ) else if "%1"=="--no-node" (
    set INCLUDE_NODE=0
  )
  set "LASTARG=%1"
  shift
  goto :loop
)

:: check our admin privileges
call utils\is_admin_cmd
set ADMIN_PRIV=%retval%

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set ROOT=%~dp0
set "ROOT=%ROOT:~0,-1%"
set "ROOT=%ROOT:\=/%"
call utils\normalize_path %ROOT%
set ROOT_WIN=%retval%

set ROOTBIN=%ROOT%/bin
call utils\normalize_path %ROOTBIN%
set ROOTBIN_WIN=%retval%

set ROOTOPT=%ROOT%/opt
call utils\normalize_path %ROOTOPT%
set ROOTOPT_WIN=%retval%

set DOWNLOADS=%ROOT%/downloads
call utils\normalize_path %DOWNLOADS%
set DOWNLOADS_WIN=%retval%

set ROOTBUILD=%ROOT%/build
call utils\normalize_path %ROOTBUILD%
set ROOTBUILD_WIN=%retval%

if not exist %DOWNLOADS_WIN% mkdir %DOWNLOADS_WIN%
if not exist %ROOTBIN_WIN% mkdir %ROOTBIN_WIN%
if not exist %ROOTOPT_WIN% mkdir %ROOTOPT_WIN%
@REM mkdir %ROOTBUILD_WIN%

:: set PATH to a very minimal set of values to limit bad dependency resolution
:: I think something in my path on work laptop is polluting dependencies,
:: probably zlib since that has caused problems for me in the past on this PC
set WINSYS32=%SystemRoot%\System32
set PATH=%ROOTBIN_WIN%;%WINSYS32%;%SystemRoot%;%WINSYS32%\Wbem;%WINSYS32%\WindowsPowerShell\v1.0\;%WINSYS32%\OpenSSH\;%ProgramFiles%\dotnet\;%LOCALAPPDATA%\Microsoft\WindowsApps;%LOCALAPPDATA%\Programs\Git\bin;%ProgramFiles%\Git\cmd

:: Call other scripts
if %INCLUDE_CMAKE%==1 (call setup\cmake || goto :fail)
if %INCLUDE_LLVM%==1 (call setup\llvm || goto :fail)
if %INCLUDE_NINJA%==1 (call setup\ninja || goto :fail)
if %INCLUDE_ZIG%==1 (call setup\zig || goto :fail)
if %INCLUDE_QT%==1 (call setup\qt || goto :fail)
if %INCLUDE_VULKAN%==1 (call setup\vulkan || goto :fail)
if %INCLUDE_MINIFORGE%==1 (call setup\miniforge || goto :fail)
if %INCLUDE_GIT%==1 (call setup\git || goto :fail)
if %INCLUDE_NODE%==1 (call setup\node || goto :fail)

:: for now, just download and then exit
goto :success

:fail
utils\failure

:success
echo %GREENTEXT%Cesium buildtools environment successfully built and up to date!%DEFAULTTEXT%
cd %ROOT_WIN%
if %EXPORT_PATH%==1 (endlocal & set PATH=%PATH%)
if %ECHO_PATH%==1 echo PATH=%PATH%
