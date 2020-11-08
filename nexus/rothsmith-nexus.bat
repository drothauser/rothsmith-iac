@echo off
setlocal

:: = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
:: Evaluate argument
:: = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
if "%1"=="--help" (
   goto syntax
)
set TEMPLATE_URL="https://s3.amazonaws.com/rothsmith-iac/nexus/rothsmith-nexus.yaml"
if "%1"=="--file" (
   set TEMPLATE_URL="file://rothsmith-nexus.yaml"   
)

set AmiId="ami-0947d2ba12ee1ff75"
set ElbPort="80"
set Ec2Port="8081"
set Scaling='1,1,1'
set Ec2Type="t2.small"
set Ec2Name='OSS-Server'
set Ec2Desc='Nexus Repository Manager'
set Ec2Owner="drothauser@yahoo.com"
set SvcCode="nexus"
set ElbTier="public"
set Ec2Role="DevOps"
set VPCStack="ROTHSMITH-VPC"
set HealthCheckType="ELB"
set stackName=ROTHSMITH-NEXUS

echo ***** %Ec2Name%

aws cloudformation create-stack^
 --capabilities CAPABILITY_IAM ^
 --disable-rollback ^
 --stack-name %stackName%^
 --template-url %TEMPLATE_URL% ^
 --parameters^
    ParameterKey=AmiId,ParameterValue=^"%AmiId%^" ^
    ParameterKey=ElbPort,ParameterValue=^"%ElbPort%^" ^
    ParameterKey=Ec2Port,ParameterValue=^"%Ec2Port%^" ^
    ParameterKey=Scaling,ParameterValue=^"%Scaling%^" ^
    ParameterKey=Ec2Type,ParameterValue=^"%Ec2Type%^" ^
    ParameterKey=Ec2Name,ParameterValue=^"%Ec2Name%^" ^
    ParameterKey=Ec2Desc,ParameterValue=^"%Ec2Desc%^" ^
    ParameterKey=Ec2Owner,ParameterValue=^"%Ec2Owner%^" ^
    ParameterKey=SvcCode,ParameterValue=^"%SvcCode%^" ^
    ParameterKey=ElbTier,ParameterValue=^"%ElbTier%^" ^
    ParameterKey=Ec2Role,ParameterValue=^"%Ec2Role%^" ^
    ParameterKey=VPCStack,ParameterValue=^"%VPCStack%^" ^
    ParameterKey=HealthCheckType,ParameterValue=^"%HealthCheckType%^" 

set RC=%ERRORLEVEL%

if %RC% NEQ 0 (
   goto finish
)

echo "Creating %stackName% Stack..."
aws cloudformation wait stack-create-complete --stack-name %stackName%

if %RC% NEQ 0 (
   goto finish
)

echo "%stackName% stack has been created."
echo "Updating nexus.rothsmith.net Route 53 record set alias target with ELB host"
call nexus-route53.bat

goto finish

:syntax
   echo "Syntax: %0 [--file | --help]"
   echo Examples:
   echo    %0 --file   Use local template file to launch stack i.e. file://rothsmith-nexus.yaml
   echo    %0 --help   Command usage
   set RC=1

:finish
echo.
echo ***********************************************************************
echo * Stack launch submitted to AWS. RC = %rc%
echo ***********************************************************************
endlocal
exit /B %RC%