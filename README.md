# Turbine [![sync]][ci]

[sync]:
https://img.shields.io/badge/CFN-deploy-green.svg?style=flat-square&logo=amazon
[ci]: #get-it-working

Turbine is the set of bare metals behind a simple yet complete and efficient
Airflow setup. Deploy in a few clicks, configure in a few commands, personalize
in a few fields.

The project is intended to be easily deployed, making it great for testing,
demos and showcasing Airflow solutions. It is also expected to be easily
tinkered with, allowing it to be used in real production environments with
little extra effort.

## Overview

![Designer](https://raw.githubusercontent.com/villasv/turbine/master/aws/cloud-formation-designer.png)

The stack is composed of two main EC2 machines, one for the Airflow UI and one
for the job scheduler. Airflow worker machines are instantiated on demand when
the job queue average length grows past a certain threshold and terminated when
the queue stays empty for too long.

Supporting resources include a RDS instance to host the Airflow metadata
database, a SQS instance to be used as broker backend, an EFS instance to serve
as shared configuration and auto-scaling triggers for workers. All other
resources are the usual boilerplate to keep the wind flowing.

## Get It Working

### 0. Prerequisites

- [A key file for remote SSH access][awsdocs-keys]

[awsdocs-keys]:
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html


### 1. Deploy the CloudFormation stack

Create a new stack using the latest template definition at
[`aws\cloud-formation-template.yml`][raw-template]. The following button will
readily deploy the stack (defaults to your last used region):

[raw-template]:
https://s3.amazonaws.com/villasv/turbine/aws/cloud-formation-template.yml

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?templateURL=https://s3.amazonaws.com/villasv/turbine/aws/cloud-formation-template.yml)

The stack resources take around 10 minutes to create, while the airflow
installation and bootstrap another 3 to 5 minutes. After that you can
already access the Airflow UI and setup your own Airflow DAGs.

### 2. Setup your Airflow files

This can be done in several ways. What really matters is:

- The Airflow home directory should be accessible at `/efs/airflow`
- The DAG files directory should be accessible at `/efs/dags`

The home directory is assumed to contain the Airflow configuration file
(`airflow.cfg`). This is flexible enough to accommodate pretty much any project
structure and is easily set up with symbolic links.

The usual procedure goes as follows: SSH into the `turbine-scheduler` EC2
instance, clone your Airflow files **inside the shared directory** (`/efs`),
install your stuff and link your specific files.

```
you@machine ~/.ssh $ ssh -i "your_key.pem" ec2-user@xxx.xxx.xxx.xxx
[ec2-user@ip-yy-y-y-yyy ~]$ cd /efs
[ec2-user@ip-yy-y-y-yyy efs]$ git clone https://your.git/user/repo
[ec2-user@ip-yy-y-y-yyy efs]$ sudo pip install -r /efs/repo/requirements.txt
[ec2-user@ip-yy-y-y-yyy efs]$ sudo ln -s /efs/repo/airflow/home /efs/airflow
[ec2-user@ip-yy-y-y-yyy efs]$ sudo ln -s /efs/repo/airflow/dags /efs/dags
```

> **GOTCHA**: if you're not in `us-east-1`, using Celery requires listing your
> region as a broker transport option, until it becomes possible to enforce it
> directly with environment variables
> [(AIRFLOW-3366)](https://issues.apache.org/jira/browse/AIRFLOW-3366).
> Providing the `visibility_timeout` is also important
> [(AIRFLOW-3365)](https://issues.apache.org/jira/browse/AIRFLOW-3365).
>
> ```
> [core]
> executor = CeleryExecutor
> ...
> [celery_broker_transport_options]
> region = us-east-2
> visibility_timeout = 21600
> ```

### 3. Apply your configurations

If you change `airflow.cfg`, it's necessary to restart the Airflow processes
related to that change. If you change the scheduler heartbeat, restart the
scheduler; if you change the webserver port, restart the webserver; and so on.
Whatever the case, this can be done easily by `systemd` on each machine:

```
you@machine ~/.ssh $ ssh -i "your_key.pem" ec2-user@xxx.xxx.xxx.xxx
[ec2-user@ip-yy-y-y-yyy ~]$ sudo systemctl restart airflow
```

One way to be completely safe in any case is to always restart all airflow
process (webserver, scheduler and workers). If you have many workers, the
easiest option is to ensure 0 worker machines while doing so, either by having
an idle cluster of manually setting `MinGroupSize=MaxGroupSize=0` temporarily.

## Cluster Settings Advice

### Workers and Auto Scaling

The stack includes an estimate of the cluster load average made by analyzing the
amount of failed attempts to retrieve a task from the queue. The rationale is
detailed [elsewhere][load-metric], but the metric objective is to measure if the
cluster is correctly sized for the influx of tasks.

**The goal of the auto scaling feature is to respond to the tasks load, which
could mean an idle cluster becoming active or a busy cluster becoming idle, the
start/end of a backfill, many DAGs with similar schedules hitting their due
time, DAGs that branch to many parallel operators. Scaling in response to
machine resources like facing CPU intensive tasks is not the goal**; the latter
is a very advanced scenario and would be best handled by Celery's own [scaling
mechanism][celery-as] or offloading the computation to it's own system (like
Spark or Kubernetes) and use Airflow only for orchestration.

[load-metric]:
https://github.com/villasv/aws-airflow-stack/issues/63
[tpo-poll]:
http://docs.celeryproject.org/en/latest/getting-started/brokers/sqs.html#polling-interval
[celery-as]:
http://docs.celeryproject.org/en/latest/userguide/workers.html#autoscaling

## FAQ

1. Why is there a `Dummy` subnet in the VPC?

    There's no official support on CloudFormation for choosing in which VPC a
    RDS Instance is deployed. The only alternatives are to let it live in the
    default VPC and communicate with peering or to use DBSubnetGroup, which
    requires associated subnets that cover at least 2 Availability Zones.

## Contributing

>This project aims to be constantly evolving with up to date tooling and newer
>AWS features, as well as improving its design qualities and maintainability.
>Requests for Enhancement should be abundant and anyone is welcome to pick them
>up.
>
>Stacks can get quite opinionated. If you have a divergent fork, you may open a
>Request for Comments and we will index it. Hopefully this will help to build a
>diverse set of possible deployment models for various production needs.

See the [contribution guidelines](/CONTRIBUTING.md) for details.

You may also want to take a look at the [Citizen Code of
Conduct](/CODE_OF_CONDUCT.md).

## Licensing

> MIT License
>
> Copyright (c) 2017 Victor Villas

See the [license file](/LICENSE) for details.
