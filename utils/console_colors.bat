@echo off
:: configure console colors
for /F %%a in ('"prompt $E$S & echo on & for %%b in (1) do rem"') do set "ESC=%%a"
set DEFAULTTEXT=%ESC%[0m
set REDTEXT=%ESC%[91m
set GREENTEXT=%ESC%[92m
set YELLOWTEXT=%ESC%[93m
@REM exit /b
