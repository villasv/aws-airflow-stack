# Turbine

Turbine is the set of bare metals behind a simple yet efficient Airflow instance.

## Notable Resources

- **Interface**:

    The EC2 instance hosting the `airflow webserver` and `airflow flower` processes.

    IP: `10.0.0.10` , Public SSH: `Enabled`

- **Scheduler**:

    The EC2 instance hosting the `airflow scheduler` process.

    IP: `10.0.0.11`, Public SSH: `Enabled`

## Simplicity

Specific resources are created with hardcoded information, like private IP addresses.
This way the template is smaller and easier to read (less variable substitutions which leads to reusable string blocks) and examples easier to follow.

## Production Readiness

This is a template for a testing and prototyping stack. Production environments should:

- be more mindful about security (restrain public Internet access).
- set up supervision for Airflow processes
