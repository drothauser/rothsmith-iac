#!/bin/bash

nexusZone=$(aws route53 list-hosted-zones-by-name --dns-name "nexus.rothsmith.net" --max-items 1 | grep '"Id"' | sed "s/^.*\/\(.*\)\"\,/\1/g")

nexusElb=$(aws elbv2 describe-load-balancers | grep -i nexus | grep DNSName | awk '{print $2}' | sed 's/[\"\,]//g')

echo "****** ${nexusElb} *****"

nexusJson=$(cat ./nexus-route53.json | sed "s/XXXXXXX/${nexusElb}/")

aws route53 change-resource-record-sets --hosted-zone-id $nexusZone --change-batch "${nexusJson}"
