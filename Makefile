define message1
 Environment variable BASE_IP is required. Not set.
 		Use following command:
        "$$ my_ip=`curl ipinfo.io | jq .ip`;eval my_ip=$${my_ip[i]};my_ip="$$my_ip/32"; export BASE_IP=$$my_ip"

endef

ifndef BASE_IP
export message1
$(error $(message1))
endif

ifndef BRANCH
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
endif

ifeq ($(BRANCH),master)
BUCKET := s3://turbine-quickstart/quickstart-turbine-airflow
else
BUCKET := s3://turbine-quickstart/quickstart-turbine-airflow-$(BRANCH)
endif

# turbine-master
CURRENT_LOCAL_IP = $(BASE_IP)
# DELETE ME
AWS_REGION := eu-central-1
PROJECT_NAME := eksairflow01-staging

lint:
	cfn-lint templates/*.template

test:
	taskcat -c ./ci/taskcat.yaml

sync:
	aws s3 sync --exclude '.*' --acl public-read . $(BUCKET)

# DELETE ME
artifacts:
	aws s3 cp --recursive submodules/quickstart-aws-vpc s3://${PROJECT_NAME}-${AWS_REGION}/${PROJECT_NAME}submodules/quickstart-aws-vpc/templates/
	aws s3 cp --recursive templates/cluster s3://${PROJECT_NAME}-${AWS_REGION}/${PROJECT_NAME}templates
	aws s3 cp --recursive templates/services s3://${PROJECT_NAME}-${AWS_REGION}/${PROJECT_NAME}templates

# DELETE ME
cluster:
	aws cloudformation --region ${AWS_REGION} create-stack --stack-name ${PROJECT_NAME} \
		--template-body file://templates/turbine-master.template \
		--parameters \
		ParameterKey="AllowedWebBlock",ParameterValue="${CURRENT_LOCAL_IP}" \
		ParameterKey="DbMasterPassword",ParameterValue="super_secret" \
		ParameterKey="QSS3BucketName",ParameterValue="${PROJECT_NAME}-${AWS_REGION}" \
		ParameterKey="QSS3KeyPrefix",ParameterValue="${PROJECT_NAME}" \
		--capabilities CAPABILITY_NAMED_IAM

# DELETE ME
clean:
	aws cloudformation delete-stack --stack-name ${PROJECT_NAME}

