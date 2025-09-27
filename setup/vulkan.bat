:: cSpell:enableCompoundWords
setlocal

:: check the version before running!
set VULKAN_VERSION=1.4.321.1

:: precompute paths and file names
set VULKAN_LONGNAME=vulkansdk-windows-X64-%VULKAN_VERSION%
set VULKAN_NAME=vulkansdk-%VULKAN_VERSION%

:: test if admin
set COPYONLY=
net session >nul 2>&1 || set COPYONLY=copy_only=1

:: Make sure to use forward slashes (/) for all path separators
:: (otherwise CMake will try to interpret backslashes as escapes and fail).
:: We will assume all paths are POSIX except those ending in `_WIN`.
set VULKAN_SDK_EXE=%DOWNLOADS_WIN%/%VULKAN_LONGNAME%.exe
call utils\normalize_path %VULKAN_SDK_EXE%
set VULKAN_SDK_EXE_WIN=%retval%

set VULKAN_DIR=%ROOTOPT%/%VULKAN_NAME%
call utils\normalize_path %VULKAN_DIR%
set VULKAN_DIR_WIN=%retval%

set VULKAN_MAINT_EXE=%VULKAN_DIR%/maintenancetool.exe
call utils\normalize_path %VULKAN_MAINT_EXE%
set VULKAN_MAINT_EXE_WIN=%retval%

set VULKAN_VER_TMP=
if exist %VULKAN_MAINT_EXE_WIN% (
  setlocal EnableDelayedExpansion
  for /F "tokens=*" %%v in ('%VULKAN_MAINT_EXE_WIN% list ^| findstr /C:"com.lunarg.vulkan"') do (
    for /F "tokens=1 delims=/" %%a in ("%%v") do set "VULKAN_VER_TMP2=%%a"
    set "VULKAN_VER_TMP2=!VULKAN_VER_TMP2:* version=!"
    for /F "tokens=1 delims==" %%a in ("!VULKAN_VER_TMP2!") do set "VULKAN_VER_TMP2=%%a"
    set "VULKAN_VER_TMP2=!VULKAN_VER_TMP2:"=!"
    for /F %%x in ("!VULKAN_VER_TMP2!") do (
      endlocal
      set "VULKAN_VER_TMP=%%x"
    )
    goto :checkvulkan
  )
  endlocal
)
:checkvulkan
if not "%VULKAN_VER_TMP%" == "%VULKAN_VERSION%" (
  echo %YELLOWTEXT%Vulkan version does not match.  Setting up Vulkan.%DEFAULTTEXT%
  :: https://vulkan.lunarg.com/doc/sdk/1.4.321.1/windows/getting_started.html
  :: https://vulkan.lunarg.com/content/view/latest-sdk-version-api
  :: https://vulkan.lunarg.com/sdk/latest/windows.txt
  :: https://sdk.lunarg.com/sdk/download/latest/windows/vulkan_sdk.exe
  :: https://sdk.lunarg.com/sdk/download/1.4.321.1/windows/vulkansdk-windows-X64-1.4.321.1.exe
  if not exist %VULKAN_SDK_EXE_WIN% (curl -o %VULKAN_SDK_EXE_WIN% -L https://sdk.lunarg.com/sdk/download/%VULKAN_VERSION%/windows/%VULKAN_LONGNAME%.exe || goto :curlfail)
  cd %ROOTOPT_WIN%
  %VULKAN_SDK_EXE_WIN% --root %VULKAN_DIR_WIN% --accept-licenses --default-answer --confirm-command install %COPYONLY% || goto :installfail
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


:set_version
set "VULKAN_VER_TMP=%~1"
exit /b

:success
cd %ROOT_WIN%
endlocal & set PATH=%VULKAN_DIR_WIN%\bin;%PATH%
