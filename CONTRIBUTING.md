# Contributing

**Thanks!** If you took interest in contributing, you're already awesome. Even
more so now that you came to read these guidelines. In fact, reading through
Turbine's code and documents is a free audit that every community member
actively donates to the project and is much appreciated.

**Why?** There should be plenty of work to do, which is why organization is key.
Hopefully this short read will boost the community potential to achieve more and
faster. Infrastructure and Data related technology tends to have slow
development and adoption, but Turbine aims the opposite.

**How?** You can immediately contribute by participating in any of the [current
issues](https://github.com/villasv/turbine/issues), be it by simply giving your
opinion in the discussion or actively solving a problem. All forms of community
interaction are welcomed contributions, so writing blog posts and tutorials or
making citations at presentations and workshops are appreciated too.

**But...** It would be best if everyone tried keep chatty discussions out of the
issue tracker. The best channel is the official Airflow [Slack
channel](https://apache-airflow.slack.com/messages/CCRR5EBA7/) dedicated to AWS
deployments.

## Local Development

Tools:
- cfn-python-lint
    ```bash
    pip install --user cfn-lint
    ```

- taskcat v0.9 (requires Python 3.6)
    ```bash
    pip install --user taskcat
    ```

- aws-nuke v2.12
    ```bash
    wget https://github.com/rebuy-de/aws-nuke/releases/download/v2.12.0/aws-nuke-v2.12.0-linux-amd64
    sudo chmod +x  aws-nuke-v2.12.0-linux-amd64
    sudo mv  aws-nuke-v2.12.0-linux-amd64 /usr/bin/aws-nuke
    ```