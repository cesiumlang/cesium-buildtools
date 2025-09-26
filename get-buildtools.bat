:: cSpell:enableCompoundWords
@echo off
setlocal
call utils\console_colors.bat

set INCLUDE_CMAKE=1
set INCLUDE_LLVM=1
set INCLUDE_NINJA=1
set INCLUDE_ZIG=1
set INCLUDE_QT=0

set EXPORT_PATH=0
set LASTARG=
:loop
if not "%~1"=="" (
    if "%1"=="--export-path" (
        set EXPORT_PATH=1
    )
    set "LASTARG=%1"
    shift
    goto :loop
)

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

set DOWNLOADS=%ROOT%/downloads
call utils\normalize_path %DOWNLOADS%
set DOWNLOADS_WIN=%retval%

set ROOTBUILD=%ROOT%/build
call utils\normalize_path %ROOTBUILD%
set ROOTBUILD_WIN=%retval%

mkdir %DOWNLOADS_WIN%
mkdir %ROOTBIN_WIN%
@REM mkdir %ROOTBUILD_WIN%
@REM mklink /d %ROOTBUILD_WIN%\lib %CESIUM_SRC_WIN%\lib

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

:: for now, just download and then exit
goto :success

:fail
utils\failure

:success
echo %GREENTEXT%Cesium buildtools environment successfully built!%DEFAULTTEXT%
cd %ROOT_WIN%
if %EXPORT_PATH%==1 (endlocal & set PATH=%PATH%)
echo PATH=%PATH%
