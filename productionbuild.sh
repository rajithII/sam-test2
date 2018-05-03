#!/bin/bash
#Title           :check-s3-object-version.sh
#Aauthor         :rajith.v@iinerds.com
#Date            :12-04-2018
#Version         :0.1    
#Usage		       :This script will create a lambda version and update the prod alias with that version
#=====================================================================================================
sudo apt-get update -y

#Export variables from the file
source lambda-variables.txt

#Publishing Lambda version
aws lambda publish-version --function-name $Function_name > lambda-version.txt

#Fetching new version
New_version=$(cat lambda-version.txt | grep "Version" | awk '{ print $2 }' | tr -d '",')

#Updating prod alias with the new version
aws lambda update-alias --function-name $Function_name --name PROD --function-version $New_version



