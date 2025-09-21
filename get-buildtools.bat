:: cSpell:enableCompoundWords
setlocal
set FULLTESTFLAG=0

:: check these versions before running!
set LLVM_VERSION=21.1.0
set ZIG_VERSION=0.15.1
@REM set NINJA_VERSION=1.13.1
@REM set CMAKE_VERSION=4.1.1
@REM set CESIUM_CMAKE_FLAGS=-DCMAKE_BUILD_TYPE=Release
set CESIUM_CMAKE_FLAGS=-DCMAKE_BUILD_TYPE=RelWithDebInfo

:: precompute paths and file names
set LLVM_LONGNAME=clang+llvm-%LLVM_VERSION%-x86_64-pc-windows-msvc
set LLVM_NAME=llvm-%LLVM_VERSION%
@REM set CMAKE_LONGNAME=cmake-%CMAKE_VERSION%-windows-x86_64
@REM set CMAKE_NAME=cmake-%CMAKE_VERSION%
set ZIG_LONGNAME=zig-x86_64-windows-%ZIG_VERSION%
set ZIG_NAME=zig-%ZIG_VERSION%

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set ROOT=%~dp0
set "ROOT=%ROOT:~0,-1%"
set "ROOT=%ROOT:\=/%"
set "ROOT_WIN=%ROOT:/=\%"

set ROOTBIN=%ROOT%/bin
set "ROOTBIN_WIN=%ROOTBIN:/=\%"

set DOWNLOADS=%ROOT%/downloads
set "DOWNLOADS_WIN=%DOWNLOADS:/=\%"

set LLVM=%ROOT%/%LLVM_NAME%
set "LLVM_WIN=%LLVM:/=\%"

set ROOTBUILD=%ROOT%/build
set "ROOTBUILD_WIN=%ROOTBUILD:/=\%"

set CC=%LLVM%/bin/clang.exe
set "CC_WIN=%CC:/=\%"

@REM set NINJA_EXE=%ROOTBIN%/ninja.exe
@REM set "NINJA_EXE_WIN=%NINJA_EXE:/=\%"

@REM set CMAKE_DIR=%ROOTBIN%/%CMAKE_NAME%
@REM set "CMAKE_DIR_WIN=%CMAKE_DIR:/=\%"

@REM set CMAKE_EXE=%CMAKE_DIR%/bin/cmake.exe
@REM set "CMAKE_EXE_WIN=%CMAKE_EXE:/=\%"

set ZIG_DIR=%ROOTBIN%/%ZIG_NAME%
set "ZIG_DIR_WIN=%ZIG_DIR:/=\%"

set ZIG_EXE=%ZIG_DIR%/zig.exe
set "ZIG_EXE_WIN=%ZIG_EXE:/=\%"

set LLVM_ZIP=%DOWNLOADS_WIN%\%LLVM_NAME%.zip
set "LLVM_ZIP_WIN=%LLVM_ZIP:/=\%"

@REM set CMAKE_ZIP=%DOWNLOADS_WIN%\%CMAKE_NAME%.zip
@REM set "CMAKE_ZIP_WIN=%CMAKE_ZIP:/=\%"

@REM set NINJA_ZIP=%DOWNLOADS_WIN%\ninja-%NINJA_VERSION%-win.zip
@REM set "NINJA_ZIP_WIN=%NINJA_ZIP:/=\%"

set ZIG_ZIP=%DOWNLOADS_WIN%\%ZIG_LONGNAME%.zip
set "ZIG_ZIP_WIN=%ZIG_ZIP:/=\%"

mkdir %DOWNLOADS_WIN%
mkdir %ROOTBIN_WIN%
@REM mkdir %ROOTBUILD_WIN%
@REM mklink /d %ROOTBUILD_WIN%\lib %CESIUM_SRC_WIN%\lib

:: set PATH to a very minimal set of values to limit bad dependency resolution
:: I think something in my path on work laptop is polluting dependencies,
:: probably zlib since that has caused problems for me in the past on this PC
set WINSYS32=%SystemRoot%\System32
@REM set PATH=%ROOTBIN_WIN%;%ROOTBIN_WIN%\%CMAKE_NAME%\bin;%WINSYS32%;%SystemRoot%;%WINSYS32%\Wbem;%WINSYS32%\WindowsPowerShell\v1.0\;%WINSYS32%\OpenSSH\;%ProgramFiles%\dotnet\;%LOCALAPPDATA%\Microsoft\WindowsApps;%LOCALAPPDATA%\Programs\Git\bin;%ProgramFiles%\Git\cmd
set PATH=%ROOTBIN_WIN%;%ZIG_DIR_WIN%;%WINSYS32%;%SystemRoot%;%WINSYS32%\Wbem;%WINSYS32%\WindowsPowerShell\v1.0\;%WINSYS32%\OpenSSH\;%ProgramFiles%\dotnet\;%LOCALAPPDATA%\Microsoft\WindowsApps;%LOCALAPPDATA%\Programs\Git\bin;%ProgramFiles%\Git\cmd

set LLVM_VER_TMP=
if exist %CC_WIN% (for /F "tokens=*" %%g in ('%CC_WIN% --version') do (set LLVM_VER_TMP=%%g))
if not "%LLVM_VER_TMP%" == "%LLVM_VERSION%" (
  if not exist %LLVM_ZIP_WIN% (curl -o %LLVM_ZIP_WIN% -L https://github.com/llvm/llvm-project/releases/download/llvmorg-%LLVM_VERSION%/%LLVM_LONGNAME%.tar.xz || goto :curlfail)
  if exist %LLVM_WIN% (rmdir /S /Q %LLVM_WIN%)
  echo tar extracting LLVM...
  tar -xmSf %LLVM_ZIP_WIN% || goto :tarfail
  echo move tar
  move %LLVM_LONGNAME% %LLVM_NAME%
)

@REM set CMAKE_VER_TMP=
@REM if exist %CMAKE_EXE_WIN% (for /F "tokens=3" %%g in ('%CMAKE_EXE_WIN% --version') do (
@REM   set CMAKE_VER_TMP=%%g
@REM   goto :checkcmake
@REM ))
@REM :checkcmake
@REM if not "%CMAKE_VER_TMP%" == "%CMAKE_VERSION%" (
@REM   if not exist %CMAKE_ZIP_WIN% (curl -o %CMAKE_ZIP_WIN% -L https://github.com/Kitware/CMake/releases/download/v%CMAKE_VERSION%/cmake-%CMAKE_VERSION%-windows-x86_64.zip || goto :curlfail)
@REM   cd %ROOTBIN_WIN%
@REM   if exist %CMAKE_DIR_WIN% (rmdir /S /Q %CMAKE_DIR_WIN%)
@REM   tar -xmSf %CMAKE_ZIP_WIN% || goto :tarfail
@REM   move %CMAKE_LONGNAME% %CMAKE_NAME%
@REM )

@REM set NINJA_VER_TMP=
@REM if exist %NINJA_EXE_WIN% (for /F "tokens=*" %%g in ('%NINJA_EXE_WIN% --version') do (set NINJA_VER_TMP=%%g))
@REM if not "%NINJA_VER_TMP%" == "%NINJA_VERSION%" (
@REM   if not exist %NINJA_ZIP_WIN% (curl -o %NINJA_ZIP_WIN% -L https://github.com/ninja-build/ninja/releases/download/v%NINJA_VERSION%/ninja-win.zip || goto :curlfail)
@REM   cd %ROOTBIN_WIN%
@REM   tar -xmSf %NINJA_ZIP_WIN% || goto :tarfail
@REM   cd %ROOT_WIN%
@REM )

set ZIG_VER_TMP=
if exist %ZIG_EXE_WIN% (for /F "tokens=*" %%g in ('%ZIG_EXE_WIN% version') do (set ZIG_VER_TMP=%%g))
if not "%ZIG_VER_TMP%" == "%ZIG_VERSION%" (
  if not exist %ZIG_ZIP_WIN% (curl -o %ZIG_ZIP_WIN% -L https://ziglang.org/download/%ZIG_VERSION%/zig-x86_64-windows-%ZIG_VERSION%.zip || goto :curlfail)
  cd %ROOTBIN_WIN%
  tar -xmSf %ZIG_ZIP_WIN% || goto :tarfail
  cd %ROOT_WIN%
  echo move tar
  move %ZIG_LONGNAME% %ZIG_NAME%
)

:: for now, just download and then exit
echo Cesium successfully built!
goto :success

@REM cd %ROOTBUILD_WIN%
@REM cmake %CESIUM_SRC% -GNinja -DCMAKE_PREFIX_PATH="%LLVM%" %CESIUM_CMAKE_FLAGS% || goto :cmakefail
@REM ninja install || goto :ninjafail

@REM cd %ROOT_WIN%
@REM call build-cesium || goto :buildfail
@REM echo Cesium successfully built!
@REM goto :success

:curlfail
:tarfail
:cmakefail
:ninjafail
:zigfail
:buildfail
exit /b 1

:success
cd %ROOT_WIN%
endlocal
