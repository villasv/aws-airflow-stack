import airflow
from airflow.models import DAG
from airflow.operators.dummy_operator import DummyOperator

default_args = {
    'start_date': airflow.utils.dates.days_ago(2),
}

dag = DAG(
    dag_id='my_dag',
    default_args=default_args,
    schedule_interval='0 0 * * *',
)

DummyOperator(
    task_id='my_op',
    dag=dag,
)
