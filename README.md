# Turbine

Turbine is the set of bare metals behind a simple yet complete and efficient Airflow setup.

![Designer](https://raw.githubusercontent.com/villasv/turbine/master/aws/cloud-formation-designer.png)

## Prerequisites

You will need a key file generated in the AWS console to be associated with the created compute instances and enable SSH.

## Get It Working

### 1. Deploy the Cloud Formation Stack

Create a new stack using the YAML definition at [`aws\cloud-formation-template.yml`](https://raw.githubusercontent.com/villasv/turbine/master/aws/cloud-formation-template.yml).
    
The following button will readily deploy the template (defaults to your last used region):
    
[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?templateURL=https://s3.amazonaws.com/villasv/turbine/aws/cloud-formation-template.yml)

### 2. Setup your Airflow files

This can be done in several ways. What really matters is:

- You Airflow home folder should be accessible at `/efs/airflow`
- Your DAGs folder should be accessible at `efs/dags`

The home folder is assumed to contain the `airflow.cfg`. This is flexible enough to accommodate pretty much any project structure and easily set up with symbolic links. 

The usual procedure goes as follows: SSH into the `turbine-scheduler` EC2 instance, clone your Airflow files **inside the shared folder** (`/efs`), install your stuff and link your specific folders.

```
ssh -i "your_key.pem" ec2-user@xxx.xxx.xxx.xxx
cd /efs
git clone https://your.git/user/repo
sudo pip3 install -r /efs/repo/requirements.txt
sudo ln -s /efs/repo/airflow/home /efs/airflow
sudo ln -s /efs/repo/airflow/dags /efs/dags
```

## Most Important Resources

- **Interface**:

    The EC2 instance hosting the `airflow webserver` process.

    Public SSH: `Enabled`, Public Web Access: `Enabled`

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

1. Why is there a `Dummy` subnet in the VPC?

    There's no official support on CloudFormation for choosing in which VPC an RDS Instance is deployed. So the only alternatives are to let it live in the default VPC and use peering or to use DBSubnetGroup (which requires 2 subnets on different Availability Zones).