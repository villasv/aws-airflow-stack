#!/bin/bash -e
systemctl is-enabled --quiet airflow-scheduler &&\
    systemctl restart airflow-scheduler
systemctl is-enabled --quiet airflow-webserver &&\
    systemctl restart airflow-webserver
systemctl is-enabled --quiet airflow-workerset &&\
    systemctl restart airflow-workerset
exit 0
