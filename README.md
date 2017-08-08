# Turbine

Turbine is the set of bare metals behind a simple yet efficient Airflow setup.

![Designer](https://raw.githubusercontent.com/villasv/turbine/master/aws/cloud-formation-designer.png)

## Prerequisites

You will need a key file generated in the AWS console to be associated with the created compute instances and enable SSH.

## Get It Working

1. Deploy the Cloud Formation Stack

    Create a new stack using the YAML definition at [`aws\cloud-formation-template.yml`](https://raw.githubusercontent.com/villasv/turbine/master/aws/cloud-formation-template.yml).
    
    The following button will readily deploy the template at `us-east-1` and will name it `TurbineAirflow`:
    
    [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=TurbineAirflow&templateURL=https://s3.amazonaws.com/villasv/turbine/aws/cloud-formation-template.yml)

2. Setup your Airflow files

    SSH into the `turbine-scheduler` EC2 instance and clone your Airflow files **inside the shared folder** (`/efs`).

    ```
    ssh -i "your_key.pem" ubuntu@some.public.ec2.ip
    cd /efs
    git clone https://your.git/user/repo
    ```

    The environment has pre-configured folder locations, so just create links to your project's airflow home and DAGs folder:

    ```
    sudo ln -s /efs/repo/airflow/home /efs/airflow
    sudo ln -s /efs/repo/airflow/dags /efs/dags
    ```
    > Optionally, instead of symlinks you can override the standard Airflow configuration environment variables (`AIRFLOW_HOME` and `AIRFLOW__CORE__DAGS_FOLDER`) on the `/efs/env.sh` file. Just exporting a new variable wouldn't work everywhere.

3. Initialize the database and the Scheduler

    After installing your dependencies, go ahead and source the environment variables, initialize the system and put the scheduler to work:

    ```
    sudo pip3 install -r /efs/airflow/requirements.txt
    source /efs/env.sh
    airflow initdb
    airflow scheduler &
    ```
    
    The `&` makes the process detach, so you can exit the `SSH` session without killing the scheduler.

4. Configure the Interface

    SSH into the `turbine-interface` EC2 instance, install your dependencies and start the webserver process:

    ```
    ssh -i "your_key.pem" ubuntu@other.public.ec2.ip
    sudo pip3 install -r /efs/airflow/requirements.txt
    source /efs/env.sh
    airflow webserver &
    ```


## Most Important Resources

- **Interface**:

    The EC2 instance hosting the `airflow webserver` and `airflow flower` processes.

    Public SSH: `Enabled`

- **Scheduler**:

    The EC2 instance hosting the `airflow scheduler` process.

    Public SSH: `Enabled`

## Overview

### Simplicity
Specific resources are created with hardcoded information, like private IP addresses.
This way the template is smaller and easier to read (less variable substitutions which leads to reusable string blocks) and examples easier to follow.

### Production Readiness
This is a template for a testing and prototyping stack. Production environments should:

- be more mindful about security (restrain public Internet access).
- set up supervision for Airflow processes
- watch out for pricing fluctuations with spot instances

## Notable Forks


## FAQ
