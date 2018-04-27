#!/bin/bash    
#Title           :check-s3-object-version.sh
#Aauthor         :rajith.v@iinerds.com
#Date            :12-04-2018
#Version         :0.1    
#Usage		 :This script will retrieve the version id of latest lambda zip file from s3 bucket.
#====================================================================================================

sudo apt-get update -y
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs

#Exporting file contains lambda variables which are used in the cloudformation template
source lambda-variables.txt
source api-variables.txt
sed -i -e 's/FunctionName/'"$Function_name"'/g' Lambda/index.js

#Packaging the zip file and upload it to s3
mkdir -p lambdatest
mv -f Lambda/* lambdatest/
cd lambdatest
npm install
zip -r $Lambda_zip *
aws s3 cp $Lambda_zip s3://$S3_bucket_name/
cd ..
Current_lambda_version="\$LATEST"

#Replace the Lambda template values to the original values in inputTemplate.yaml
sed -i -e 's/Object-name/'"$Lambda_zip"'/g' inputTemplate.yaml
sed -i -e 's/Bucket-name/'"$S3_bucket_name"'/g' inputTemplate.yaml
sed -i -e 's/Lambda-function-name/'"$Function_name"'/g' inputTemplate.yaml
sed -i -e 's/Function-description/'"$Function_description"'/g' inputTemplate.yaml
sed -i -e 's/Runtime-env/'"$Runtime_env"'/g' inputTemplate.yaml

#Replace the API template values to the original values in inputTemplate.yaml
sed -i -e 's/APIName/'"$API_Name"'/g' inputTemplate.yaml
sed -i -e 's/API-Description/'"$API_Description"'/g' inputTemplate.yaml
sed -i -e 's/Path-Part/'"$Path_Part"'/g' inputTemplate.yaml

#Substitute the value of S3ObjectVersion with the current version id of zip file which is uploaded to s3 bucket.
Version_id=$(aws s3api get-object --bucket aadhri-test-buck --key $Lambda_zip outfile | grep "VersionId" | awk '{ print $2 }'| tr -d '",')
if [ $? != 0 ]; then
	   echo "Version does not exist"
else
	   sed -i -e 's/Obj-version-id/'"$Version_id"'/' inputTemplate.yaml  
fi

#Pointing prod alias with the current version of lambda function. This step is necessary to keep the production always points to the current version of lambda during the update stack process. 
Lambda_version=$(aws lambda get-alias --function-name $Function_name --name PROD | grep "FunctionVersion" | awk '{print $2}' | tr -d '",')

if [ $? != 0 ]; then
	sed 's/$LATEST/'"$Current_lambda_version"'/g' inputTemplate.yaml
else
	sed ':a;N;$!ba;s/\$LATEST/'"$Lambda_version"'/3' inputTemplate.yaml
fi

#Packaging the cloudformation template
aws cloudformation package --template-file inputTemplate.yaml --s3-bucket $S3_bucket_name --output-template-file outputTemplate.yaml
