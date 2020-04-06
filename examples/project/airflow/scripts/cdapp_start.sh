#!/bin/bash -e
systemctl is-enabled --quiet airflow-scheduler &&\
    systemctl start airflow-scheduler
systemctl is-enabled --quiet airflow-webserver &&\
    systemctl start airflow-webserver
systemctl is-enabled --quiet airflow-workerset &&\
    systemctl start airflow-workerset
exit 0
