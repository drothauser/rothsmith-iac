@echo off
setlocal enabledelayedexpansion

for /F "tokens=3 delims=/," %%i in ('aws route53 list-hosted-zones-by-name --dns-name ^"nexus.rothsmith.net^" --max-items 1 ^| findstr ^"\^"Id\^":^"') do (
   set nexusZoneTmp=%%i
   set nexusZone=!nexusZoneTmp:"=!
)
echo Nexus Zone = %nexusZone%

for /F "tokens=2 delims=:," %%i in ('aws elbv2 describe-load-balancers ^| findstr -i nexus ^| findstr DNSName') do (
   set nexusElbTmp=%%i
   set nexusElb=!nexusElbTmp:"=!
   set nexusElb=!nexusElb: =!
)
echo Nexus ELB = %nexusElb%

set /P nexusJsonRaw=<./nexus-route53.json

set nexusJson=!nexusJsonRaw:XXXXXXX=%nexusElb%!
echo Route53 JSON = !nexusJson!
echo !nexusJson! > %TEMP%\nexusRoute53.json

aws route53 change-resource-record-sets --hosted-zone-id %nexusZone% --change-batch file://%TEMP%\nexusRoute53.json
