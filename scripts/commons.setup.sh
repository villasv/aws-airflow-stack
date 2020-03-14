#!/bin/bash -xe

echo ">> Running Commons setup script ..."
SCRIPTS=$(dirname "$0")

echo ">>> Installing Python and Airflow ..."
yum install -y \
    gcc libcurl-devel openssl-devel \
    python3 python3-devel python3-wheel
PYCURL_SSL_LIBRARY=openssl pip3 install \
    "celery[sqs]" "apache-airflow[celery,postgres,s3,crypto]==1.10.9"
echo ">>> Installing Python and Airflow [OK]"

echo ">>> Placing systemd files ..."
cp "$SCRIPTS"/systemd/*.path /lib/systemd/system/
cp "$SCRIPTS"/systemd/*.service /lib/systemd/system/
cp "$SCRIPTS"/systemd/airflow.env /etc/sysconfig/airflow.env
cp "$SCRIPTS"/systemd/airflow.conf /usr/lib/tmpfiles.d/airflow.conf
mkdir -p /etc/cfn/hooks.d
cp "$SCRIPTS"/systemd/cfn-hup.conf /etc/cfn/cfn-hup.conf
cp "$SCRIPTS"/systemd/cfn-auto-reloader.conf /etc/cfn/hooks.d/cfn-auto-reloader.conf
echo ">>> Placing systemd files [OK]"

echo ">>> Fetching the Fernet secret ..."
while [ "$FERNET_KEY" = "" ]; do
    sleep 1
    FERNET_KEY=$(aws ssm get-parameter \
        --name "$SECRET_KEY_NAME" \
        --region "$AWS_REGION" \
        --with-decryption \
        --query 'Parameter.Value' \
        --output text)
done
echo ">>> Fetching the Fernet secret [OK]"

echo ">>> Preparing CodeDeploy agent ..."
cd_pending() {
    DEPLOYMENTS=$(aws deploy list-deployments \
        --application-name "$CODE_DEPLOY_APP" \
        --deployment-group "$CODE_DEPLOY_GROUP" \
        --region "$AWS_REGION" \
        --query 'deployments | length(@)')
    if [ "$DEPLOYMENTS" == "" ] || [ "$DEPLOYMENTS" == "0" ]
    then echo "false"; else echo "true"; fi
}
cd_agent() {
    yum install -y ruby
    wget "https://aws-codedeploy-$AWS_REGION.s3.amazonaws.com/latest/install"
    chmod +x ./install
    ./install auto
}
echo ">>> Preparing CodeDeploy agent [OK]"

echo ">>> Cofiguring Airflow environment ..."
mkdir /airflow && chown -R ec2-user: /airflow
envreplace() {
    CONTENT=$(envsubst <"$1")
    echo "$CONTENT" >"$1"
}
envreplace /etc/sysconfig/airflow.env
envreplace /etc/cfn/cfn-hup.conf
envreplace /etc/cfn/hooks.d/cfn-auto-reloader.conf
mapfile -t AIRFLOW_ENVS < /etc/sysconfig/airflow.env
export "${AIRFLOW_ENVS[@]}"
echo ">>> Cofiguring Airflow environment [OK]"

systemctl enable --now cfn-hup.service

echo ">> Running Commons setup script [OK]"
