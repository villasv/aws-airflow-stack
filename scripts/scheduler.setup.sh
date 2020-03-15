#!/bin/bash -xe

yum install -y python3
pip3 install cryptography
FERNET_KEY=$(aws ssm get-parameter \
    --name "$SECRET_KEY_NAME" \
    --region "$AWS_REGION" \
    --query 'Parameter.Value' || true)
if [ "$FERNET_KEY" = "" ];
then
    FERNET_KEY=$(python3 -c "if True:#
        from cryptography.fernet import Fernet
        key = Fernet.generate_key().decode()
        print(key)")
    aws ssm put-parameter \
        --name "$SECRET_KEY_NAME" \
        --region "$AWS_REGION" \
        --value "$FERNET_KEY" \
        --type SecureString
fi

. "$(dirname $0)/commons.setup.sh"

if [ "$TURBINE__CORE__LOAD_DEFAULTS" == "True" ]; then
    su -c '/usr/local/bin/airflow initdb' ec2-user
else
    su -c '/usr/local/bin/airflow upgradedb' ec2-user
fi

systemctl enable --now airflow-scheduler
cd_agent
