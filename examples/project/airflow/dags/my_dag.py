from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
import silly

default_args = {
    "start_date": datetime(2019, 1, 1),
}

with DAG(
    "my_dag", default_args=default_args, schedule_interval=timedelta(days=1)
) as dag:

    setup_task = BashOperator(
        task_id="setup",
        bash_command='echo "setup initiated" && sleep 5 && echo "done"',
    )

    def fetch_companies():
        return [silly.company(capitalize=True) for _ in range(5)]

    fetch_companies_task = PythonOperator(
        task_id="fetch_companies", python_callable=fetch_companies,
    )
    setup_task >> fetch_companies_task

    def generate_reports(**context):
        companies = context["task_instance"].xcom_pull(task_ids="fetch_companies")
        reports = [
            f"# '{company}' Report\n\n{silly.markdown()}" for company in companies
        ]
        return reports

    generate_reports_task = PythonOperator(
        task_id="generate_reports",
        python_callable=generate_reports,
        provide_context=True,
    )
    fetch_companies_task >> generate_reports_task

    teardown_task = BashOperator(
        task_id="teardown",
        bash_command='echo "teardown initiated" && sleep 5 && echo "done"',
    )
    generate_reports_task >> teardown_task
