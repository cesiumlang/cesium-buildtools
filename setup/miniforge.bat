:: cSpell:enableCompoundWords
setlocal

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set MINIFORGE_INSTALL_EXE=%DOWNLOADS%/Miniforge3-Windows-x86_64.exe
call utils\normalize_path %MINIFORGE_INSTALL_EXE%
set MINIFORGE_INSTALL_EXE_WIN=%retval%

set MINIFORGE_DIR=%ROOTOPT%/miniforge3
call utils\normalize_path %MINIFORGE_DIR%
set MINIFORGE_DIR_WIN=%retval%

if not exist %MINIFORGE_DIR_WIN% set FORCE_MINIFORGE=1
if %FORCE_MINIFORGE%==1 (
  echo %YELLOWTEXT%Setting up Miniconda.%DEFAULTTEXT%
  if not exist %MINIFORGE_INSTALL_EXE_WIN% (curl -o %MINIFORGE_INSTALL_EXE_WIN% -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe || goto :curlfail)
  if exist %MINIFORGE_DIR_WIN% (rmdir /S /Q %MINIFORGE_DIR_WIN%)
  cd %ROOTOPT_WIN%
  %MINIFORGE_INSTALL_EXE_WIN% /InstallationType=JustMe /RegisterPython=0 /S /D=%MINIFORGE_DIR_WIN% || goto :installfail
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
:installfail
echo %REDTEXT%install failure%DEFAULTTEXT%
exit /b 4

:success
cd %ROOT_WIN%
endlocal & set PATH=%MINIFORGE_DIR_WIN%\miniforge3\condabin;%PATH%
