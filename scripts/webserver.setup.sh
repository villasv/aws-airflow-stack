#!/bin/bash -e

. "$(dirname $0)/commons.setup.sh"

PUBLIC=$(curl "$IMDSv1/meta-data/public-ipv4" -w "%{http_code}")
if [ "$PUBLIC" = "200" ]
then HOSTNAME=$(ec2-metadata -v | awk '{print $2}')
else HOSTNAME=$(ec2-metadata -o | awk '{print $2}')
fi
BASE_URL="http://$HOSTNAME:${WEB_SERVER_PORT}"
echo "AIRFLOW__WEBSERVER__BASE_URL=$BASE_URL" \
  >> /etc/sysconfig/airflow.env
echo "AIRFLOW__WEBSERVER__WEB_SERVER_PORT=${WEB_SERVER_PORT}" \
  >> /etc/sysconfig/airflow.env

systemctl enable --now airflow-webserver
cd_agent
