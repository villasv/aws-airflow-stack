ifdef ENV
SUFFIX = -$(ENV)
endif

S3URI = s3://turbine-quickstart/quickstart-turbine-airflow$(SUFFIX)

lint:
	cfn-lint templates/*.template

test:
	rm -r taskcat_outputs ||:
	taskcat -c ./ci/taskcat.yaml $(TASKCAT_FLAGS)

quiz:
	@echo "Uploading files to $(S3URI)"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]

sync: quiz
	aws s3 sync --exclude '.*' --acl public-read . $(S3URI)
