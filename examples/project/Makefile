ifndef stack-name
$(error stack-name is not set)
endif
ifndef revision
revision := $(shell date --utc +%Y%m%dT%H%M%SZ)
endif


# deployment variables
REVISION := $(shell date --utc +%Y%m%dT%H%M%SZ)
PACKAGE = $(stack-name)_$(REVISION).tgz
define getRef
$(shell aws cloudformation describe-stacks \
	--stack-name $(stack-name) \
	--query "Stacks[0].Outputs[?OutputKey=='$(1)'].OutputValue" \
	--output text)
endef
APPLICATION := $(call getRef,CodeDeployApplication)
DEPLOYMENT_GROUP := $(call getRef,CodeDeployDeploymentGroup)
DEPLOYMENTS_BUCKET := $(call getRef,DeploymentsBucket)

# stack resources
APPLICATION = $(stack-name)-deployment-application
DEPLOYMENT_GROUP = $(stack-name)-deployment-group
DEPLOYMENTS_BUCKET = $(shell aws cloudformation describe-stack-resources --stack-name $(stack-name) --logical-resource-id DeploymentsBucket --query 'StackResources[0].PhysicalResourceId' --output text)

PACKAGE := $(stack-name)_$(revision).tgz


package:
	cd airflow && tar czf ../$(PACKAGE) .
