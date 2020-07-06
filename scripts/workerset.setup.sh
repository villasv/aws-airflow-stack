#!/bin/bash -e

. "$(dirname $0)/commons.setup.sh"

if [ ! -d "/mnt/efs" ]; then
    mkdir /mnt/efs
    FSPEC="${FILE_SYSTEM_ID}.efs.$AWS_REGION.amazonaws.com:/"
    PARAMS="nfsvers=4.1,rsize=1048576,wsize=1048576"
    PARAMS="$PARAMS,hard,timeo=600,retrans=2,noresvport"
    echo "$FSPEC /mnt/efs nfs $PARAMS,_netdev 0 0" >> /etc/fstab
    mount /mnt/efs && chown -R ec2-user: /mnt/efs
fi

if [ "$CD_PENDING_DEPLOY" = "false" ]; then
    systemctl enable --now airflow-workerset
else
    systemctl enable airflow-workerset
fi
cd_agent
