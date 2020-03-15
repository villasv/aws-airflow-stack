#!/bin/bash -xe

. "$(dirname $0)/commons.setup.sh"

systemctl enable --now airflow-webserver
cd_agent
