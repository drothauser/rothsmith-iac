#!/bin/bash
#if [ $# -eq 0 ]
#  then
#    echo "You must supply a stack name argument!"
#    exit 1
#fi

AmiId="ami-0947d2ba12ee1ff75"
ElbPort="80"
Ec2Port="8081"
Scaling='1,1,1'
Ec2Type="t2.medium"
Owner="drothauser@yahoo.com"
OrgCode="rothsmith"
ServiceDesc="Nexus_OSS"
ServiceName='Nexus'
ElbTier="public"
ServiceProfile="DevOps"
NexusVersion="3.28.1-01"
VPCStack="ROTHSMITH-VPC"
HealthCheckType="ELB"
stackName="ROTHSMITH-NEXUS"

templateBodyUrl='https://s3.amazonaws.com/rothsmith-iac/nexus/rothsmith-nexus.yaml'
if [ "$1" == "--file" ]
then
  templateBodyUrl='file://rothsmith-nexus.yaml'
fi

if aws cloudformation create-stack\
 --capabilities CAPABILITY_IAM \
 --disable-rollback \
 --stack-name ${stackName}\
 --template-url ${templateBodyUrl} \
 --parameters\
    ParameterKey=AmiId,ParameterValue=\"${AmiId}\" \
    ParameterKey=ElbPort,ParameterValue=\"${ElbPort}\" \
    ParameterKey=Ec2Port,ParameterValue=\"${Ec2Port}\" \
    ParameterKey=Scaling,ParameterValue=\"${Scaling}\" \
    ParameterKey=Ec2Type,ParameterValue=\"${Ec2Type}\" \
    ParameterKey=ServiceName,ParameterValue=\"${ServiceName}\" \
    ParameterKey=ServiceDesc,ParameterValue=\"${ServiceDesc}\" \
    ParameterKey=Owner,ParameterValue=\"${Owner}\" \
    ParameterKey=OrgCode,ParameterValue=\"${OrgCode}\" \
    ParameterKey=ElbTier,ParameterValue=\"${ElbTier}\" \
    ParameterKey=ServiceProfile,ParameterValue=\"${ServiceProfile}\" \
    ParameterKey=NexusVersion,ParameterValue=\"${NexusVersion}\" \
    ParameterKey=VPCStack,ParameterValue=\"${VPCStack}\" \
    ParameterKey=HealthCheckType,ParameterValue=\"${HealthCheckType}\"

then
   echo "Creating $stackName Stack..."
   if aws cloudformation wait stack-create-complete --stack-name $stackName
   then
      echo "$stackName stack has been created."
      echo "Updating nexus.rothsmith.net Route 53 record alias target with ELB host"
      bash ./nexus-route53.sh
   fi
fi

RC=$?

echo
echo "***********************************************************************"
echo "* $0 completed. RC = $RC"
echo "***********************************************************************"
exit $RC
