:: example use:
::
::   call utils\is_admin_cmd
::   set ADMIN_PRIV=%retval%
::

:: https://stackoverflow.com/a/8995407/13230486
set retval=0
net session >nul 2>&1 || set retval=1
exit /b
