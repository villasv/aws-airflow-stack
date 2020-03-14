#!/bin/bash -xe

. "$(dirname $0)/commons.setup.sh"

echo ">> Starting WorkerSet setup..."

if [ "$(cd_pending)" == "true" ]; then
    echo "Deployment pending, deferring service start"
else
    systemctl start airflow-workerset
fi

cd_agent
systemctl enable airflow-workerset
