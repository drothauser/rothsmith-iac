zoneId=`aws route53 list-hosted-zones-by-name | grep -B 1 -e "rothsmith.net" | sed 's/.*hostedzone\/\([A-Za-z0-9]*\)\".*/\1/' | head -n 1`
aws route53 change-resource-record-sets --hosted-zone-id $zoneId --change-batch file://rothsmith-route53-update-apex-a.json
