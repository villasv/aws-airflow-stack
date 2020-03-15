#!/bin/bash -xe

. "$(dirname $0)/commons.setup.sh"

systemctl enable --now airflow-workerset
cd_agent
