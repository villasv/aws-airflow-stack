ifndef stack-name
$(error stack-name is not set)
endif

# stack logical names
APPLICATION = $(stack-name)-deployment-application
DEPLOYMENT_GROUP = $(stack-name)-deployment-group
DEPLOYMENTS_BUCKET = $(stack-name)-deployments

# deployment variables
REVISION := $(shell date --utc +%Y%m%dT%H%M%SZ)
PACKAGE = $(stack-name)_$(REVISION).tgz


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
