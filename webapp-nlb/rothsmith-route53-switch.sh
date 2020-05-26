#!/bin/bash 

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# This script is run during the UI server initialization process
# to set the Route53 Record Set for the given NLB DNS name to be 
# the standby record set in a weighted/failover routing policy
# scenario.
#
# This is necessary because Route53's normal behavior is to failback
# to the orignally declared primary record set and that causes 
# the web application to reauthentication users.
#
# Ultimately, what we're trying to achieve is that when a failover
# event occurs and requests are directed to the new server (NLB), 
# we want it to stick there and not failback to a new server once
# it is stood up.
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

function syntax() {
   echo "Syntax: $0 [NLB DNS name]"
   echo "Examples:"
   echo "   $0 web-webserver2-public-ae5bc70146e5688c.elb.us-east-1.amazonaws.com."
   exit 1
}

function createChangeRequest() {
	
	recordSet=$(echo ${1}|tr -d '\n\r')	
	role="$2"
	
	if [[ ${role} == "primary" ]]
	then
		comment="Set Record Set to Primary"		
		changeRecordSet=$(echo "${recordSet}" | perl -pe 's/"SetIdentifier": "\w+"/"SetIdentifier": "primary"/g' | perl -pe 's/"Weight": \w+/"Weight": 100/g')
	else
		comment="Set Record Set to Standby"		
		changeRecordSet=$(echo "${recordSet}" | perl -pe 's/"SetIdentifier": "\w+"/"SetIdentifier": "standby"/g' | perl -pe 's/"Weight": \w+/"Weight": 0/g')
	fi
			
	changeRequest=$(cat <<EOF
{
	"Comment": "${comment}",
	"Changes": [
		{
			"Action": "UPSERT",
			"ResourceRecordSet": ${changeRecordSet}
		}
	]
}	
EOF
	)
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Validate DNS name argument.
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
if [ "$1" == "" ]; then
   syntax
fi
DNSNAME=$(echo "${1}" | tr '[:upper:]' '[:lower:]')

echo "*** DNS Name: ${DNSNAME}"

hostedZone=$(aws route53 list-hosted-zones-by-name --dns-name "test.rothsmith.net" --max-items 1 --output text --query "HostedZones[].Id" | sed 's/\/hostedzone\///g')
echo "*** Hosted Zone Id: ${hostedZone}"

# = = = = = = = = = = = = = = = = = = = = = = =
# Find record set for the given DNSNAME.  
# We'll be making this the standby record set.
# = = = = = = = = = = = = = = = = = = = = = = = 
myRecordSet=$(aws route53 list-resource-record-sets --hosted-zone-id ${hostedZone} --query "ResourceRecordSets[?AliasTarget] | [?contains (AliasTarget.DNSName, \`${DNSNAME}\`)]" | perl -pe 's/[\[\]]\s*//g')
if [ "${myRecordSet}" == "null" ] || [ "${myRecordSet}" == '' ]
then
	echo "Route53 Record Sets not set up (this is ok if you see this during stack creation)"
	exit 0
fi
createChangeRequest "${myRecordSet}" standby
echo "*** Change Record Set For Standby"
echo "${changeRequest}"
myChangeRequest="${changeRequest}"

# = = = = = = = = = = = = = = = = = = 
# Toggle Standby to Primary 
# = = = = = = = = = = = = = = = = = = 
otherRecordSet=$(aws route53 list-resource-record-sets --hosted-zone-id ${hostedZone} --query "ResourceRecordSets[?AliasTarget] | [?contains (AliasTarget.DNSName, \`${DNSNAME}\`) == \`false\`]" | perl -pe 's/[\[\]]\s*//g')
createChangeRequest "${otherRecordSet}" primary
echo "*** Change Record Set For Primary"
echo "${changeRequest}"
otherChangeRequest="${changeRequest}"

RC=0
aws route53 change-resource-record-sets --hosted-zone-id ${hostedZone} --change-batch "${myChangeRequest}" && \
aws route53 change-resource-record-sets --hosted-zone-id ${hostedZone} --change-batch "${otherChangeRequest}"
RC=$?

exit ${RC}