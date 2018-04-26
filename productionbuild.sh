#!/bin/bash
sudo apt-get update -y
source lambda-variables.txt
aws lambda publish-version --function-name $Function_name > lambda-version.txt
New_version=$(cat lambda-version.txt | grep "Version" | awk '{ print $2 }' | tr -d '",')
aws lambda update-alias --function-name $Function_name --name PROD --function-version $New_version



