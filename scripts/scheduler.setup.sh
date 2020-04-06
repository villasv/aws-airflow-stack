#!/bin/bash -e

. "$(dirname $0)/commons.setup.sh"

if [ "$TURBINE__CORE__LOAD_DEFAULTS" == "True" ]; then
    su -c '/usr/local/bin/airflow initdb' ec2-user
else
    su -c '/usr/local/bin/airflow upgradedb' ec2-user
fi

systemctl enable --now airflow-scheduler
cd_agent
