#!/bin/bash    
#title           :check-s3-object-version.sh
#author		 :rajith.v@iinerds.com
#date            :12-04-2018
#version         :0.1    
#usage		 :This script will retrieve the version id of latest lambda zip file from s3 bucket.
#====================================================================================================
sed -i -e 's/object_name/'"$1"'/g' data.yaml
version_id=$(aws s3api get-object --bucket aadhri-test-buck --key $1 outfile | grep "VersionId" | awk '{ print $2 }'| tr -d '",')
if [ $? != 0 ]; then
	   echo "Version does not exist"
else
	   sed -i -e 's/obj_version_id/'"$version_id"'/' data.yaml  
fi

functionversion=$(aws lambda get-alias --function-name GreetingLambda --name PROD | grep "FunctionVersion" | awk '{print $2}' | tr -d '",')

if [ $? != 0 ]; then
	echo "No version found"
else
	sed ':a;N;$!ba;s/\$LATEST/'"$functionversion"'/3' data.yaml
fi

