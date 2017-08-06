# Turbine

Turbine is the set of bare metals behind a simple yet efficient Airflow instance.

## Get It Working

1. Deploy the Cloud Formation Stack

    Create a new stack using the YAML definition at `aws\cloud-formation.yaml`.
    
    If you're not tweaking yet, the following button will readily deploy the model at `us-east-1` and will name it `TurbineAirflow`:
    
    [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=TurbineAirflow&templateURL=https://s3.amazonaws.com/villasv/turbine/cloud-formation.yaml)

2. Get your System running

## Most Important Resources

- **Interface**:

    The EC2 instance hosting the `airflow webserver` and `airflow flower` processes.

    IP: `10.0.0.10` , Public SSH: `Enabled`

- **Scheduler**:

    The EC2 instance hosting the `airflow scheduler` process.

    IP: `10.0.0.11`, Public SSH: `Enabled`

## Overview

### Simplicity
Specific resources are created with hardcoded information, like private IP addresses.
This way the template is smaller and easier to read (less variable substitutions which leads to reusable string blocks) and examples easier to follow.

### Production Readiness
This is a template for a testing and prototyping stack. Production environments should:

- be more mindful about security (restrain public Internet access).
- set up supervision for Airflow processes

## Notable Forks
