#!/bin/bash -e
yum install -y jq
jsonvar() { jq -n --argjson doc "$1" -r "\$doc.$2"; }

IMDSv1="http://169.254.169.254/latest"
AWS_PARTITION=$(curl "$IMDSv1/meta-data/services/partition")
export AWS_PARTITION

IAM_ROLE=$(curl "$IMDSv1/meta-data/iam/security-credentials")
IAM_DOCUMENT=$(curl "$IMDSv1/meta-data/iam/security-credentials/$IAM_ROLE")
AWS_ACCESS_KEY_ID=$(jsonvar "$IAM_DOCUMENT" AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(jsonvar "$IAM_DOCUMENT" SecretAccessKey)
AWS_SECURITY_TOKEN=$(jsonvar "$IAM_DOCUMENT" Token)
export IAM_ROLE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SECURITY_TOKEN

EC2_DOCUMENT=$(curl "$IMDSv1/dynamic/instance-identity/document")
AWS_REGION=$(jsonvar "$EC2_DOCUMENT" region)
AWS_DEFAULT_REGION=$(jsonvar "$EC2_DOCUMENT" region)
AWS_ACCOUNT_ID=$(jsonvar "$EC2_DOCUMENT" accountId)
EC2_INSTANCE_ID=$(jsonvar "$EC2_DOCUMENT" instanceId)
export AWS_DEFAULT_REGION AWS_REGION AWS_ACCOUNT_ID EC2_INSTANCE_ID

yum install -y python3 python3-pip python3-wheel python3-devel
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

DB_SECRETS=$(aws secretsmanager \
    get-secret-value --secret-id "$DB_SECRETS_ARN")
DB_ENGINE=$(jsonvar "$DB_SECRETS" "SecretString | fromjson.engine")
DB_USER=$(jsonvar "$DB_SECRETS" "SecretString | fromjson.username")
DB_PASS=$(jsonvar "$DB_SECRETS" "SecretString | fromjson.password")
DB_HOST=$(jsonvar "$DB_SECRETS" "SecretString | fromjson.host")
DB_DBNAME=$(jsonvar "$DB_SECRETS" "SecretString | fromjson.dbname")
DB_PORT=$(jsonvar "$DB_SECRETS" "SecretString | fromjson.port")
DATABASE_URI="$DB_ENGINE://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT/$DB_DBNAME"
export DATABASE_URI

yum install -y python3
pip3 install cryptography
FERNET_KEY=$(python3 -c "if True:#
    from base64 import urlsafe_b64encode
    from cryptography.fernet import Fernet
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),length=32,iterations=100000,
		backend=default_backend(),salt=b'${FERNET_SALT//\'/\\\'}',
    )
    key = kdf.derive(b'${DB_PASS_ESC//\'/\\\'}')
    key_encoded = urlsafe_b64encode(key)
    print(key_encoded.decode('utf8'))")
export FERNET_KEY

FILES=$(dirname "$0")
find "$FILES" -type f -iname "*.sh" -exec chmod +x {} \;
envreplace() { CONTENT=$(envsubst <"$1"); echo "$CONTENT" >"$1"; }

mkdir -p /etc/cfn/hooks.d
cp "$FILES"/systemd/cfn-hup.service /lib/systemd/system/
cp "$FILES"/systemd/cfn-hup.conf /etc/cfn/cfn-hup.conf
cp "$FILES"/systemd/cfn-auto-reloader.conf /etc/cfn/hooks.d/cfn-auto-reloader.conf
envreplace /etc/cfn/cfn-hup.conf
envreplace /etc/cfn/hooks.d/cfn-auto-reloader.conf

mkdir /run/airflow && chown -R ec2-user: /run/airflow
cp "$FILES"/systemd/airflow-*.{path,timer,service} /lib/systemd/system/
cp "$FILES"/systemd/airflow.env /etc/sysconfig/airflow.env
cp "$FILES"/systemd/airflow.conf /usr/lib/tmpfiles.d/airflow.conf
envreplace /etc/sysconfig/airflow.env

mapfile -t AIRFLOW_ENVS < /etc/sysconfig/airflow.env
export "${AIRFLOW_ENVS[@]}"

yum install -y gcc libcurl-devel openssl-devel
export PYCURL_SSL_LIBRARY=openssl
pip3 install "apache-airflow[celery,postgres,s3,crypto]==1.10.9" "celery[sqs]"
mkdir "$AIRFLOW_HOME" && chown -R ec2-user: "$AIRFLOW_HOME"

systemctl enable --now cfn-hup.service

cd_agent() {
    yum install -y ruby
    wget "https://aws-codedeploy-$AWS_REGION.s3.amazonaws.com/latest/install"
    chmod +x ./install
    ./install auto
}
