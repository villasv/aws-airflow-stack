ifndef stack-name
$(error stack-name is not set)
endif

# deployment variables
REVISION := $(shell date --utc +%Y%m%dT%H%M%SZ)
PACKAGE = $(stack-name)_$(REVISION).tgz

# stack resources
APPLICATION = $(stack-name)-deployment-application
DEPLOYMENT_GROUP = $(stack-name)-deployment-group
DEPLOYMENTS_BUCKET = $(shell aws cloudformation describe-stack-resources --stack-name $(stack-name) --logical-resource-id DeploymentsBucket --query 'StackResources[0].PhysicalResourceId' --output text)


package:
	cd airflow && tar czf ../$(PACKAGE) .

upload: package
	aws s3 cp $(PACKAGE) s3://$(DEPLOYMENTS_BUCKET)

deploy: upload
	aws deploy create-deployment \
		--application-name $(APPLICATION) \
		--deployment-group-name $(DEPLOYMENT_GROUP) \
		--s3-location bucket=$(DEPLOYMENTS_BUCKET),bundleType=tgz,key=$(PACKAGE) \
		--deployment-config-name CodeDeployDefault.AllAtOnce \
		--file-exists-behavior OVERWRITE
