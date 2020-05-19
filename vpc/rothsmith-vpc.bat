@echo off
setlocal

:: = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
:: Evaluate argument
:: = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
if "%1"=="--help" (
   goto syntax
)
set TEMPLATE_URL="https://s3.amazonaws.com/rothsmith-iac/vpc/rothsmith-vpc.yaml"
if "%1"=="--file" (
   set TEMPLATE_URL="file://rothsmith-vpc.yaml"   
)

aws cloudformation create-stack^
 --capabilities CAPABILITY_IAM ^
 --disable-rollback ^
 --stack-name ROTHSMITH-VPC^
 --template-body %TEMPLATE_URL% ^
 --parameters^
    ParameterKey=KeyPairName,ParameterValue=^"RothsmithKeyPair^"  

set RC=%ERRORLEVEL%
if "%RC%" NEQ "0" goto finish

aws cloudformation wait stack-create-complete --stack-name ROTHSMITH-VPC
set RC=%ERRORLEVEL%

goto finish

:syntax
   echo "Syntax: %0 [--file | --help]"
   echo Examples:
   echo    %0 --file   Use local template file to launch stack i.e. file://rothsmith-vpc.yaml
   echo    %0 --help   Command usage
   set RC=1

:finish
echo.
echo ***********************************************************************
echo * Stack launch submitted to AWS. RC = %rc%
echo ***********************************************************************
endlocal
exit /B %RC%