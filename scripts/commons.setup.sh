#!/bin/bash -xe
FILES=$(dirname "$0")

yum install -y jq
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
AWS_ACCOUNT_ID=$(jq -n --argjson doc "$EC2_DOCUMENT" -r '$doc.accoundId')
EC2_INSTANCE_ID=$(jq -n --argjson doc "$EC2_DOCUMENT" -r '$doc.instanceId')
export AWS_REGION EC2_INSTANCE_ID

EC2_HOST_IDENTIFIER="arn:$AWS_PARTITION:ec2:$AWS_REGION:$AWS_ACCOUNT_ID"
EC2_HOST_IDENTIFIER="$EC2_HOST_IDENTIFIER:instance/$EC2_INSTANCE_ID"

awscurl -X POST --service codedeploy-commands https://codedeploy-commands.us-east-1.amazonaws.com -d '{"HostIdentifier": ""}' -H "Content-Type: application/x-amz-json-1.1" -H "X-AMZ-TARGET: CodeDeployCommandService_v20141006.PollHostCommand"

# AWS_STACK_NAME=$(aws ec2 describe-instances \
#   --instance-id "$EC2_INSTANCE_ID" \
#   --query "Reservations[*].Instances[*].Tags[?Key=='aws:cloudformation:stack-name'].Value" \
#   --region "$AWS_REGION" \
#   --output text)

yum install -y \
    gcc libcurl-devel openssl-devel \
    python3 python3-devel python3-wheel
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
