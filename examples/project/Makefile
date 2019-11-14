ifndef stack-name
$(error stack-name is not set)
endif
ifndef revision
revision := $(shell date --utc +%Y%m%dT%H%M%SZ)
endif


define getRef
$(shell aws cloudformation describe-stacks \
	--stack-name $(stack-name) \
	--query "Stacks[0].Outputs[?OutputKey=='$(1)'].OutputValue" \
	--output text)
endef
APPLICATION := $(call getRef,CodeDeployApplication)
DEPLOYMENT_GROUP := $(call getRef,CodeDeployDeploymentGroup)
DEPLOYMENTS_BUCKET := $(call getRef,DeploymentsBucket)


PACKAGE := $(stack-name)_$(revision).tgz


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
