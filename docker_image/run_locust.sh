#!/bin/bash

# Check locustfile.py exists (retry 10 times * 10 seconds)
RETRY=0
TARGET_FILE="my-locust-files/locustfile.py"
while [ ! -f /locust/$TARGET_FILE ]; do
    RETRY=$(expr $RETRY + 1)

    if [ $RETRY -gt 10 ]; then 
        echo "Retry attempts exceeded, exit script"
        exit $RETRY
    fi

    echo "locustfile.py doesn't exist. Retry ... ($RETRY)"
    sleep 10
done

COMMON_ARGS="-f $TARGET_FILE"

# Master / Worker mode
if [ -z $LOCUST_MODE ]; then
    locust $COMMON_ARGS
elif [ $LOCUST_MODE == "master" ]; then
    locust --master $COMMON_ARGS
else
    locust --worker --master-host $LOCUST_MASTER_HOST $COMMON_ARGS
fi