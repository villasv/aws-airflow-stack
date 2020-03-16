#!/bin/bash
if [ "$(systemctl is-active airflow)" = "deactivating" ]; then
    aws autoscaling record-lifecycle-action-heartbeat \
    --instance-id "$(ec2-metadata -i | awk '{print $2}')" \
    --lifecycle-hook-name "$AWS_STACK_NAME-scaling-lfhook" \
    --auto-scaling-group-name "$AWS_STACK_NAME-scaling-group" \
    --region "$AWS_REGION"
fi
