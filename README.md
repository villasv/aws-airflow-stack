<meta property="og:title" content="Turbine AWS Airflow Stack">
<meta property="og:description" content="the bare metals behind a complete Airflow setup">
<meta property="og:image" content="img/logo.png">
<meta property="og:url" content="https://victor.villas/aws-airflow-stack/">
<meta name="twitter:card" content="summary">
<img src="img/logo.png" align="right" width="25%" />

# Turbine [![](https://img.shields.io/badge/CFN-deploy-green.svg?style=flat-square&logo=amazon)](#get-it-working) [![](https://img.shields.io/github/stars/villasv/aws-airflow-stack.svg?logo=github&style=flat-square)](https://github.com/villasv/aws-airflow-stack)

Turbine is the set of bare metals behind a simple yet complete and efficient
Airflow setup.

The project is intended to be easily deployed, making it great for testing,
demos and showcasing Airflow solutions. It is also expected to be easily
tinkered with, allowing it to be used in real production environments with
little extra effort. Deploy in a few clicks, personalize in a few fields,
configure in a few commands.

## Overview

![Designer](/aws/cloud-formation-designer.png)

The stack is composed mainly of two EC2 machines, one for the Airflow webserver
and one for the Airflow scheduler, plus an Auto Scaling Group of EC2 machines
for Airflow workers. Supporting resources include an RDS instance to host the
Airflow metadata database, an SQS instance to be used as broker backend, S3
buckets for logs and deployment bundles, an EFS instance to serve as shared
directory, and auto scaling metrics, alarms and triggers. All other resources
are the usual boilerplate to keep the wind blowing.

### Deployment and File Sharing

The deployment process through CodeDeploy is very flexible and can be tailored
for each project structure, the only invariant being the Airflow home directory
at `/airflow`. It ensures that every Airflow process has the same files and can
upgraded gracefully, but most importantly makes deployments really fast and easy
to begin with.

There's also an EFS shared directory mounted at at `/mnt/efs`, which can be
useful for staging files potentially used by workers on different machines and
other syncrhonization scenarios commonly found in ETL/Big Data applications. It
facilitates migrating legacy workloads not ready for running on distributed
workers.

### Workers and Auto Scaling

The stack includes an estimate of the cluster load average made by analyzing the
amount of failed attempts to retrieve a task from the queue. The rationale is
detailed [elsewhere](https://github.com/villasv/aws-airflow-stack/issues/63),
but the metric objective is to measure if the cluster is correctly sized for the
influx of tasks. Worker instances have lifecycle hooks promoting a graceful
shutdown, waiting for tasks completion when terminating.

**The goal of the auto scaling feature is to respond to changes in queue load,
which could mean an idle cluster becoming active or a busy cluster becoming
idle, the start/end of a backfill, many DAGs with similar schedules hitting
their due time, DAGs that branch to many parallel operators. Scaling in response
to machine resources like facing CPU intensive tasks is not the goal**; the
latter is a very advanced scenario and would be best handled by Celery's own
scaling mechanism or offloading the computation to another system (like Spark or
Kubernetes) and use Airflow only for orchestration.

## Get It Working

### 0. Prerequisites

- A key file for remote SSH access
  [(Guide)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

- Configured AWS CLI for deploying your own files [(Guide)](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

### 1. Deploy the stack

Create a new stack using the latest template definition at
[`aws/cloud-formation-template.yml`](/aws/cloud-formation-template.yml). The
following button will deploy the stack available in this project's `master`
branch (defaults to your last used region):

[![Launch](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?templateURL=https://s3.amazonaws.com/villasv/turbine/aws/cloud-formation-template.yml)

The stack resources take around 10 minutes to create, while the airflow
installation and bootstrap another 3 to 5 minutes. After that you can already
access the Airflow UI and deploy your own Airflow DAGs.

### 2. Upstream your files

The only requirement is that you configure the deployment to copy your Airflow
home directory to `/airflow`. After crafting your `appspec.yml`, you can use the
AWS CLI to deploy your project.

For convenience, you can use this [`Makefile`](/src/Makefile) to handle the
packaging, upload and deployment commands. A minimal working example of an
Airflow project to deploy can be found at [`src/airflow`](/src/airflow).

If you follow this blueprint, a deployment is as simple as:

```bash
make deploy stack-name=yourcoolstackname
```

> **GOTCHA**: if you rely on the default connections, be sure to configure
> `aws_default` to use the appropriate region!

## FAQ

1. Why is there an empty `Dummy` subnet in the VPC?

    There's no official support on CloudFormation for choosing in which VPC a
    RDS Instance is deployed. The only alternatives are to let it live in the
    default VPC and communicate with peering or to use DBSubnetGroup, which
    requires associated subnets that cover at least 2 Availability Zones.

2. Why does auto scaling takes so long to kick in?

    AWS doesn't provide minute-level granularity on SQS metrics, only 5 minute
    aggregates. Also, CloudWatch stamps aggregate metrics with their initial
    timestamp, meaning that the latest stable SQS metrics are from 10 minutes in
    the past. This is why the load metric is always 5~10 minutes delayed. To
    avoid oscillating allocations, the alarm action has a 10 minutes cooldown.

3. Why can't I stop running tasks by terminating all workers?

    Workers have lifecycle hooks that make sure to wait for Celery to finish its
    tasks before allowing EC2 to terminate that instance (except maybe for Spot
    Instances going out of capacity). If you want to kill running tasks, you
    will need to SSH into worker instances and stop the airflow service
    forcefully.

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

Did this project help you? Consider buying me a cup of coffee ;-)

[![Buy me a coffee!](https://www.buymeacoffee.com/assets/img/custom_images/white_img.png)](https://www.buymeacoffee.com/villasv)

## Licensing

> MIT License
>
> Copyright (c) 2017 Victor Villas

See the [license file](/LICENSE) for details.
