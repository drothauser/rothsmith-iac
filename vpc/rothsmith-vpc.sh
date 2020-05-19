#!/bin/bash

function syntax() {
   echo "Syntax: $0 [--file | --help]"
   echo "Examples:"
   echo "   $0 --file   Use local template file to launch stack i.e. file://rothsmith-vpc.yaml"
   echo "   $0 --help   Command usage"
   exit 1
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Evaluate argument
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
if [ "$1" = "--help" ]; then
   syntax
fi

stackName="ROTHSMITH-VPC"

TEMPLATE_URL="https://s3.amazonaws.com/rothsmith-iac/vpc/rothsmith-vpc.yaml"
if [ "$1" = "--file" ]; then
   TEMPLATE_URL="file://rothsmith-vpc.yaml"   
fi

if aws cloudformation create-stack\
 --capabilities CAPABILITY_IAM \
 --disable-rollback \
 --stack-name $stackName\
 --template-body $TEMPLATE_URL \
 --parameters\
    ParameterKey=KeyPairName,ParameterValue=\"RothsmithKeyPair\"  
then
   echo "Creating $stackName Stack..."
   aws cloudformation wait stack-create-complete --stack-name $stackName
   echo "$stackName stack has been created."
fi

RC=$?

echo
echo "***********************************************************************"
echo "* $0 completed. RC = $RC"
echo "***********************************************************************"
exit $RC