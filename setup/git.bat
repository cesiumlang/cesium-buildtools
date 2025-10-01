:: cSpell:enableCompoundWords
setlocal

:: Git is unique from the others here in that it really needs to be installed
:: systemwide like Visual Studio.
if %FORCE_GIT%==1 goto :gitdownload

setlocal EnableDelayedExpansion
  set GIT_EXE=
  for /f "tokens=*" %%a in ('where git') do (
    set GIT_EXE=%%a
    goto :checkgit
  )
  :checkgit
  if exist !GIT_EXE! for /f "tokens=*" %%a in ('git -v') do (
    for /f "tokens=1" %%b in ("%%a") do (
      if "%%b"=="git" for /f "tokens=2" %%c in ("%%a") do (
        if "%%c"=="version" goto :updategit
      )
    )
  )
endlocal

:gitdownload
echo %YELLOWTEXT%Git not found or install forced.  Setting up Git.%DEFAULTTEXT%
:: git did not exist, so we need to download and install

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set GIT_VERSION_FILE=%DOWNLOADS%/git_latest_release.json
call utils\normalize_path %GIT_VERSION_FILE%
set GIT_VERSION_FILE_WIN=%retval%

set GIT_INSTALL_EXE=%DOWNLOADS%/git-installer.exe
call utils\normalize_path %GIT_INSTALL_EXE%
set GIT_INSTALL_EXE_WIN=%retval%

echo Querying GitHub API for the latest Git release...
curl -o %GIT_VERSION_FILE_WIN% -L https://api.github.com/repos/git-for-windows/git/releases/latest || goto :curlfail
if not exist %GIT_VERSION_FILE_WIN% goto :curlfail

:: Step 1: Find the line containing the download URL for the 64-bit installer
for /f "tokens=* usebackq" %%a in (`findstr /i "\"browser_download_url\":" %GIT_VERSION_FILE_WIN% ^| findstr /i /r "Git-.*-64-bit.exe"`) do (
  setlocal EnableDelayedExpansion
    for /f tokens^=3^ delims^=^" %%b in ("%%a") do (
    curl -o %GIT_INSTALL_EXE_WIN% -L %%b || goto :curlfail
    endlocal
    goto :gitinstall
  )
  :: only gets here if the URL not found in first for
  endlocal
  goto :github_api_parse_fail
)
:gitinstall
echo Installing Git...
%GIT_INSTALL_EXE_WIN% /o:CRLFOption=CRLFCommitAsIs /SILENT /NORESTART /NOCANCEL /SP- || goto :installfail
echo Git installed.
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
:github_api_parse_fail
echo %REDTEXT%GitHub API response parse failure%DEFAULTTEXT%
exit /b 4

:updategit
echo %YELLOWTEXT%Attempt updating existing git%DEFAULTTEXT%
git update-git-for-windows -y

:success
cd %ROOT_WIN%
endlocal & set PATH=%MINIFORGE_DIR_WIN%\miniforge3\condabin;%PATH%
