#!/bin/bash -xe
FILES=$(dirname "$0")
yum install -y jq python3 python3-devel python3-wheel

IMDSv1="http://169.254.169.254/latest"
AWS_PARTITION=$(curl "$IMDSv1/meta-data/services/partition")
export AWS_PARTITION

IAM_ROLE=$(curl "$IMDSv1/meta-data/iam/security-credentials")
IAM_DOCUMENT=$(curl "$IMDSv1/meta-data/iam/security-credentials/$IAM_ROLE")
AWS_ACCESS_KEY_ID=$(jq -n --argjson doc "$IAM_DOCUMENT" -r '$doc.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(jq -n --argjson doc "$IAM_DOCUMENT" -r '$doc.SecretAccessKey')
AWS_SECURITY_TOKEN=$(jq -n --argjson doc "$IAM_DOCUMENT" -r '$doc.Token')
export IAM_ROLE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SECURITY_TOKEN

EC2_DOCUMENT=$(curl "$IMDSv1/dynamic/instance-identity/document")
AWS_REGION=$(jq -n --argjson doc "$EC2_DOCUMENT" -r '$doc.region')
AWS_ACCOUNT_ID=$(jq -n --argjson doc "$EC2_DOCUMENT" -r '$doc.accountId')
EC2_INSTANCE_ID=$(jq -n --argjson doc "$EC2_DOCUMENT" -r '$doc.instanceId')
export AWS_REGION AWS_ACCOUNT_ID EC2_INSTANCE_ID

pip3 install awscurl
EC2_HOST_IDENTIFIER="arn:$AWS_PARTITION:ec2:$AWS_REGION:$AWS_ACCOUNT_ID"
EC2_HOST_IDENTIFIER="$EC2_HOST_IDENTIFIER:instance/$EC2_INSTANCE_ID"
CD_COMMAND=$(/usr/local/bin/awscurl -X POST \
    --service codedeploy-commands \
    "https://codedeploy-commands.$AWS_REGION.amazonaws.com" \
    -H "X-AMZ-TARGET: CodeDeployCommandService_v20141006.PollHostCommand" \
    -H "Content-Type: application/x-amz-json-1.1" \
    -d "{\"HostIdentifier\": \"$EC2_HOST_IDENTIFIER\"}")
if [ "$CD_COMMAND" = "" ] || [ "$CD_COMMAND" = "b'{}'" ]
then CD_PENDING_DEPLOY="false"
else CD_PENDING_DEPLOY="true"
fi
export CD_PENDING_DEPLOY

while [ "$FERNET_KEY" = "" ]; do
    sleep 1
    FERNET_KEY=$(aws ssm get-parameter \
        --name "$SECRET_KEY_NAME" \
        --region "$AWS_REGION" \
        --with-decryption \
        --query 'Parameter.Value' \
        --output text)
done
export FERNET_KEY

yum install -y gcc libcurl-devel openssl-devel
PYCURL_SSL_LIBRARY=openssl pip3 install \
    "celery[sqs]" "apache-airflow[celery,postgres,s3,crypto]==1.10.9"

cp "$FILES"/systemd/*.path /lib/systemd/system/
cp "$FILES"/systemd/*.service /lib/systemd/system/
cp "$FILES"/systemd/airflow.env /etc/sysconfig/airflow.env
cp "$FILES"/systemd/airflow.conf /usr/lib/tmpfiles.d/airflow.conf
mkdir -p /etc/cfn/hooks.d
cp "$FILES"/systemd/cfn-hup.conf /etc/cfn/cfn-hup.conf
cp "$FILES"/systemd/cfn-auto-reloader.conf /etc/cfn/hooks.d/cfn-auto-reloader.conf
find "$FILES" -type f -iname "*.sh" -exec chmod +x {} \;

cd_agent() {
    yum install -y ruby
    wget "https://aws-codedeploy-$AWS_REGION.s3.amazonaws.com/latest/install"
    chmod +x ./install
    ./install auto
}

mkdir /airflow && chown -R ec2-user: /airflow
mkdir /run/airflow && chown -R ec2-user: /run/airflow
envreplace() {
    CONTENT=$(envsubst <"$1")
    echo "$CONTENT" >"$1"
}
envreplace /etc/sysconfig/airflow.env
envreplace /etc/cfn/cfn-hup.conf
envreplace /etc/cfn/hooks.d/cfn-auto-reloader.conf
mapfile -t AIRFLOW_ENVS < /etc/sysconfig/airflow.env
export "${AIRFLOW_ENVS[@]}"

systemctl enable --now cfn-hup.service
