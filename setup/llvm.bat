:: cSpell:enableCompoundWords
setlocal

:: check the version before running!
set LLVM_VERSION=21.1.0

:: precompute paths and file names
set LLVM_LONGNAME=clang+llvm-%LLVM_VERSION%-x86_64-pc-windows-msvc
set LLVM_NAME=llvm-%LLVM_VERSION%

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set LLVM=%ROOTOPT%/%LLVM_NAME%
call utils\normalize_path %LLVM%
set LLVM_WIN=%retval%

set LLVM_ZIP=%DOWNLOADS%/%LLVM_NAME%.zip
call utils\normalize_path %LLVM_ZIP%
set LLVM_ZIP_WIN=%retval%

set CC=%LLVM%/bin/clang.exe
call utils\normalize_path %CC%
set CC_WIN=%retval%

set LLVM_VER_TMP=
if exist %CC_WIN% (for /F "tokens=3" %%g in ('%CC_WIN% --version') do (
  set LLVM_VER_TMP=%%g
  goto :checkllvm
))
:checkllvm
if not "%LLVM_VER_TMP%" == "%LLVM_VERSION%" (
  echo %YELLOWTEXT%Clang version does not match.  Setting up LLVM.%DEFAULTTEXT%
  if not exist %LLVM_ZIP_WIN% (curl -o %LLVM_ZIP_WIN% -L https://github.com/llvm/llvm-project/releases/download/llvmorg-%LLVM_VERSION%/%LLVM_LONGNAME%.tar.xz || goto :curlfail)
  if exist %LLVM_WIN% (rmdir /S /Q %LLVM_WIN%)
  cd %ROOTOPT_WIN%
  echo tar extracting LLVM...
  tar -xmSf %LLVM_ZIP_WIN% || goto :tarfail
  echo move tar
  move %LLVM_LONGNAME% %LLVM_NAME% || goto :movefail
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
endlocal & set PATH=%LLVM%\bin;%PATH%
