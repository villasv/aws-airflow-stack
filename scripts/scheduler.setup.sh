#!/bin/bash -xe

echo ">>> Checking cluster secret key ..."
yum install -y python3
pip3 install cryptography
FERNET_KEY=$(aws ssm get-parameter \
    --name "$SECRET_KEY_NAME" \
    --region "$AWS_REGION" \
    --query 'Parameter.Value' || true)
if [ "$FERNET_KEY" = "" ];
then
    echo ">>>> Key not found, will generate one"
    FERNET_KEY=$(python3 -c "if True:#
        from cryptography.fernet import Fernet
        key = Fernet.generate_key().decode()
        print(key)")
    aws ssm put-parameter \
        --name "$SECRET_KEY_NAME" \
        --region "$AWS_REGION" \
        --value "$FERNET_KEY" \
        --type SecureString
else
    echo ">>>> Key already exists"
fi
echo ">>> Checking cluster secret key [OK]"

. "$(dirname $0)/commons.setup.sh"

echo ">> Starting Scheduler setup..."

if [ "$TURBINE__CORE__LOAD_DEFAULTS" == "True" ]; then
    /usr/local/bin/airflow initdb
else
    /usr/local/bin/airflow upgradedb
fi

if [ "$(cd_pending)" == "true" ]; then
    echo "Deployment pending, deferring service start"
else
    systemctl start airflow-scheduler
fi

cd_agent
systemctl enable airflow-scheduler
