#!/bin/bash

# Download Locustfile from S3
if [ -z $S3_ENDPOINT ]; then
    aws s3 cp s3://$S3_BUCKET/$S3_KEY locustfile.py
else
    # For S3 Compatible Storage
    aws --endpoint-url $S3_ENDPOINT s3 cp s3://$S3_BUCKET/$S3_KEY locustfile 
fi

# Master / Worker mode
if [ -z $LOCUST_MODE ]; then
    locust
elif [ $LOCUST_MODE == "master" ]; then
    locust --master
else
    locust --worker --master-host $LOCUST_MASTER_HOST
fi