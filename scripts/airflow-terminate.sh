#!/bin/bash
INSTANCE_ID=$(ec2-metadata -i | awk '{print $2}')
TERMINATE_MESSAGE="Terminating EC2 instance <$INSTANCE_ID>"
TERMINATING=$(aws autoscaling describe-scaling-activities \
    --auto-scaling-group-name "$ClusterStack-scaling-group" \
    --max-items 100 \
    --region "$AWS_REGION" | \
    jq --arg TERMINATE_MESSAGE "$TERMINATE_MESSAGE" \
    '.Activities[]
    | select(.Description
    | test($TERMINATE_MESSAGE)) != []')
if [ "$TERMINATING" = "true" ]; then
    systemctl stop airflow
fi