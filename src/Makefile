# stack logical names
APPLICATION = $(StackName)-deployment-application
DEPLOYMENT_GROUP = $(StackName)-deployment-group
DEPLOYMENTS_BUCKET = $(StackName)-deployments

# deployment variables
REVISION := $(shell date +%Y%m%d-%H%M%S)
PACKAGE = airflow-package-$(REVISION).tgz

ifndef StackName
$(error StackName is not set)
endif

package:
	cd airflow && tar czf ../$(PACKAGE) .

upload: package
	aws s3 cp $(PACKAGE) s3://$(DEPLOYMENTS_BUCKET)

deploy: upload
	aws deploy create-deployment \
		--application-name $(APPLICATION) \
		--deployment-group-name $(DEPLOYMENT_GROUP) \
		--deployment-config-name CodeDeployDefault.AllAtOnce \
		--s3-location bucket=$(DEPLOYMENTS_BUCKET),bundleType=tgz,key=$(PACKAGE)
