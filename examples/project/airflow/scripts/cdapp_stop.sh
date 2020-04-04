#!/bin/bash -e
systemctl is-enabled --quiet airflow-scheduler &&\
    systemctl stop airflow-scheduler
systemctl is-enabled --quiet airflow-webserver &&\
    systemctl stop airflow-webserver
systemctl is-enabled --quiet airflow-workerset &&\
    systemctl stop airflow-workerset
exit 0
