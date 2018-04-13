#!/bin/bash    
#Title           :check-s3-object-version.sh
#Aauthor         :rajith.v@iinerds.com
#Date            :12-04-2018
#Version         :0.1    
#Usage		 :This script will retrieve the version id of latest lambda zip file from s3 bucket.
#====================================================================================================

#Substitute the value of S3Key with the zip file which is uploaded to s3. 
sed -i -e 's/object_name/'"$1"'/g' data.yaml

#Substitute the value of S3ObjectVersion with the current version id of zip file which is uploaded to s3 bucket.
version_id=$(aws s3api get-object --bucket aadhri-test-buck --key $1 outfile | grep "VersionId" | awk '{ print $2 }'| tr -d '",')
if [ $? != 0 ]; then
	   echo "Version does not exist"
else
	   sed -i -e 's/obj_version_id/'"$version_id"'/' data.yaml  
fi

#Pointing prod alias with the current version of lambda function. This step is necessary to keep the production always points to the current version of lambda during the update stack process. 
functionversion=$(aws lambda get-alias --function-name GreetingLambda --name PROD | grep "FunctionVersion" | awk '{print $2}' | tr -d '",')

if [ $? != 0 ]; then
	echo "No version found"
else
	sed ':a;N;$!ba;s/\$LATEST/'"$functionversion"'/3' data.yaml
fi

