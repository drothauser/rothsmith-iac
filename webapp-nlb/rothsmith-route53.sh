#!/bin/bash

rothsmithZone=$(aws route53 list-hosted-zones-by-name --dns-name "rothsmith.net" --max-items 1 | grep '"Id"' | sed "s/^.*\/\(.*\)\"\,/\1/g")

rothsmithElb=$(aws elbv2 describe-load-balancers | grep -i 'web-public' | grep DNSName | awk '{print $2}' | sed 's/[\"\,]//g')

echo "****** ${rothsmithElb} *****"

rothsmithJson=$(cat ./rothsmith-route53.json | sed "s/XXXXXXX/${rothsmithElb}/")

aws route53 change-resource-record-sets --hosted-zone-id $rothsmithZone --change-batch "${rothsmithJson}"
