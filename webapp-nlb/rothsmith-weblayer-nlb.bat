@echo off
setlocal

:: = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
:: Evaluate argument
:: = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
if "%1"=="--help" (
   goto syntax
)
set TEMPLATE_URL="https://s3.amazonaws.com/rothsmith-iac/webapp-nlb/rothsmith-weblayer-nlb.yaml"
if "%1"=="--file" (
   set TEMPLATE_URL="file://rothsmith-apps-nlb.yaml"   
)

aws cloudformation create-stack^
 --capabilities CAPABILITY_IAM ^
 --disable-rollback ^
 --stack-name ROTHSMITH-WEBLAYER-NLB^
 --template-url %TEMPLATE_URL% ^
 --parameters^
    ParameterKey=VPCStack,ParameterValue=^"ROTHSMITH-VPC^" ^
    ParameterKey=S3Bucket,ParameterValue=^"rothsmith-iac^" 

set RC=%ERRORLEVEL%
goto finish

:syntax
   echo "Syntax: %0 [--file | --help]"
   echo Examples:
   echo    %0 --file   Use local template file to launch stack i.e. file://rothsmith-weblayer.yaml
   echo    %0 --help   Command usage
   set RC=1

:finish
echo.
echo ***********************************************************************
echo * Stack launch submitted to AWS. RC = %rc%
echo ***********************************************************************
endlocal
exit /B %RC%