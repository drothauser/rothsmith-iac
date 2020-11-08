@echo off
setlocal

call ./rothsmith-vpc.bat
set RC=%ERRORLEVEL%
if "%RC%" NEQ "0" goto finish

call  ./rothsmith-nexus.bat

set RC=%ERRORLEVEL%

:finish
echo.
echo ***********************************************************************
echo * %0 finished. RC = %rc%
echo ***********************************************************************
endlocal
exit /B %RC%

