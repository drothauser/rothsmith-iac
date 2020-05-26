#!/bin/bash 

function toggleChangeRequest() {
	
	recordSet=$(echo ${1}|tr -d '\n\r')	
	
	if [[ ${recordSet} == *"primary"* ]]
	then
		comment="Toggle Primary to Standby"
		toggleRecordSet=$(echo "${recordSet}" | perl -pe 's/primary/standby/g' | perl -pe 's/"Weight": 100/"Weight": 0/g')
	else
		comment="Toggle Standby to Primary"
		toggleRecordSet=$(echo "${recordSet}" | perl -pe 's/standby/primary/g' | perl -pe 's/"Weight": 0/"Weight": 100/g')
	fi
			
	changeRequest=$(cat <<EOF
{
	"Comment": "${comment}",
	"Changes": [
		{
			"Action": "UPSERT",
			"ResourceRecordSet": ${toggleRecordSet}
		}
	]
}	
EOF
	)
}

hostedZone=$(aws route53 list-hosted-zones-by-name --dns-name "test.rothsmith.net" --max-items 1 --output text --query "HostedZones[].Id" | sed 's/\/hostedzone\///g')
echo "Hosted Zone Id: ${hostedZone}"

# = = = = = = = = = = = = = = = = = = 
# Toggle Primary to Standby
# = = = = = = = = = = = = = = = = = =  
primaryRecordSet=$(aws route53 list-resource-record-sets --hosted-zone-id ${hostedZone} --query "ResourceRecordSets[?SetIdentifier == \`primary\`]" | perl -pe 's/[\[\]]\s*//g')
if [[ "${primaryRecordSet}" == "" ]] 
then
	echo "Route53 Record Sets not set up (this is ok if you see this during stack creation)"
	exit
fi
toggleChangeRequest "${primaryRecordSet}" 
echo "Primary to Standby Change Request:"
echo "${changeRequest}"
p2s="${changeRequest}"

# = = = = = = = = = = = = = = = = = = 
# Toggle Standby to Primary 
# = = = = = = = = = = = = = = = = = = 
standbyRecordSet=$(aws route53 list-resource-record-sets --hosted-zone-id ${hostedZone} --query "ResourceRecordSets[?SetIdentifier == \`standby\`]" | perl -pe 's/[\[\]]\s*//g')
toggleChangeRequest "${standbyRecordSet}" 
echo "Standby to Primary Change Request:"
echo "${changeRequest}"
s2p="${changeRequest}"

aws route53 change-resource-record-sets --hosted-zone-id ${hostedZone} --change-batch "${p2s}"
aws route53 change-resource-record-sets --hosted-zone-id ${hostedZone} --change-batch "${s2p}"
