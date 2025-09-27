:: example use:
::
::   call utils\normalize_path %path_a%\..
::   set path_b=%retval%
::
:: sets path_b to the resolved path (rather than just appending \.. to the string)

:: see: https://stackoverflow.com/a/33404867/13230486
set retval=%~f1
@REM echo %retval%
exit /b
