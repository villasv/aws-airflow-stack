# Turbine [![sync]][ci] [![rver]][gh]

[sync]:
https://img.shields.io/scrutinizer/build/g/villasv/turbine.svg?style=flat-square&label=sync
[ci]:
https://scrutinizer-ci.com/g/villasv/turbine/build-status/master
[rver]:
https://img.shields.io/github/release/villasv/turbine.svg?style=flat-square
[gh]:
https://github.com/villasv/turbine/releases

Turbine is the set of bare metals behind a simple yet complete and efficient Airflow setup. Deploy in a few clicks, configure in a few commands, personalize in a few fields.

![Designer](https://raw.githubusercontent.com/villasv/turbine/master/aws/cloud-formation-designer.png)

## Overview

The stack is composed of two main EC2 machines (one for the Airflow Web Server and one for the Airflow Scheduler). Airflow Worker machines are instantiated on demand when the job queue average length grows past a certain threshold (initially 10) and terminated when the queue average length shrinks below another threshold (initially 5).

Supporting resources include a RDS instance to host the Airflow Metadata Database, a SQS instance to be used as broker backend and an EFS instance to serve as shared configuration and logging location for all machines.

All other resources are the usual boilerplate to have the above working, including networking and Internet connectivity, security specifications, availability zone coverage and authentication mechanisms.

The project is intended to be easily deployed, making it great for testing, demoing and showcasing Airflow solutions. It is also expected to be easily tinkered, allowing it to be used in real production environments with little extra effort.

## Get It Working

### 0. Prerequisites

You will need a key file generated in the AWS console to be associated with the created compute instances and enable SSH.

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

Optionally, you can reset the database to remove the default example DAGs that were loaded in the bootstrap process. Be careful to do this only when Airflow is idle, as to not leave it in an inconsistent state.

```
airflow resetdb
```


## FAQ

1. Why is there a `Dummy` subnet in the VPC?

    There's no official support on CloudFormation for choosing in which VPC an RDS Instance is deployed. So the only alternatives are to let it live in the default VPC and use peering or to use DBSubnetGroup (which requires 2 subnets on different Availability Zones).

## Contributing

> Stacks can get quite opinionated. If you have a divergent fork, you may open a RFC issue and we will 

See the [contribution guidelines](https://github.com/villasv/turbine/blob/master/CONTRIBUTING.md) for details.

## Licensing

> MIT License
>
> Copyright (c) 2017 Victor Villas

See the [license file](/LICENSE) for details.