#!/bin/bash -xe

. "$(dirname $0)/commons.setup.sh"

echo ">> Starting Webserver setup..."

if [ "$(cd_pending)" == "true" ]; then
    echo "Deployment pending, deferring service start"
else
    systemctl start airflow-webserver
fi

cd_agent
systemctl enable airflow-webserver
