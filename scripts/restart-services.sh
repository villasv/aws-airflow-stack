#!/bin/bash
systemctl is-active --quiet airflow-scheduler &&\
    systemctl restart airflow-scheduler
systemctl is-active --quiet airflow-webserver &&\
    systemctl restart airflow-webserver
systemctl is-active --quiet airflow-workerset &&\
    systemctl restart airflow-workerset
exit 0
