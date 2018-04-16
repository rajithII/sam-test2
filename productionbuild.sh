#!/bin/bash
aws lambda publish-version --function-name GreetingLambda > lambda-version.txt
new-version=$(cat lambda-version.txt | grep "Version" | awk '{ print $2 }' | tr -d '",')
aws lambda update-alias --function-name GreetingLambda --name PROD --function-version $new-version



