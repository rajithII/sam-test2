#!/bin/bash    
#Title           :check-s3-object-version.sh
#Aauthor         :rajith.v@iinerds.com
#Date            :12-04-2018
#Version         :0.1    
#Usage		     :This script will retrieve the version id of latest lambda zip file from s3 bucket.
#====================================================================================================

sudo apt-get update -y
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs

#Exporting file contains lambda variables which are used in the cloudformation template
source lambda-variables.txt

#Packaging the zip file and upload it to s3
mkdir -p lambdatest
mv -f Lambda/* lambdatest/
cd lambdatest
npm install
zip -r $lambda_zip *
aws s3 cp $lambda_zip s3://$s3_bucket_name/
cd ..

#Replace the template values to the original values in data.yaml
sed -i -e 's/object-name/'"$lambda_zip"'/g' data.yaml
sed -i -e 's/bucket-name/'"$s3_bucket_name"'/g' data.yaml
sed -i -e 's/lambda-function-name/'"$function_name"'/g' data.yaml
sed -i -e 's/function-description/'"$function_description"'/g' data.yaml
sed -i -e 's/runtime-env/'"$runtime_env"'/g' data.yaml

#Substitute the value of S3ObjectVersion with the current version id of zip file which is uploaded to s3 bucket.
version_id=$(aws s3api get-object --bucket aadhri-test-buck --key $1 outfile | grep "VersionId" | awk '{ print $2 }'| tr -d '",')
if [ $? != 0 ]; then
	   echo "Version does not exist"
else
	   sed -i -e 's/obj-version-id/'"$version_id"'/' data.yaml  
fi

#Pointing prod alias with the current version of lambda function. This step is necessary to keep the production always points to the current version of lambda during the update stack process. 
lambda_version=$(aws lambda get-alias --function-name GreetingLambda --name PROD | grep "FunctionVersion" | awk '{print $2}' | tr -d '",')

if [ $? != 0 ]; then
	echo "No version found"
else
	sed ':a;N;$!ba;s/\$LATEST/'"$lambda_version"'/3' data.yaml
fi

#Packaging the cloudformation template
aws cloudformation package --template-file data.yaml --s3-bucket $s3_bucket_name --output-template-file outputdata.yaml