ifndef BRANCH
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
endif

ifeq ($(BRANCH),master)
BUCKET := s3://turbine-quickstart/quickstart-turbine-airflow
else
BUCKET := s3://turbine-quickstart/quickstart-turbine-airflow-$(BRANCH)
endif


lint:
	cfn-lint templates/*.template

nuke:
	aws-nuke -c ci/awsnuke.yaml --profile turbine --force --no-dry-run

sync:
	7z a ./functions/package.zip ./functions/*.py
	aws s3 sync --exclude '.*' --acl public-read . $(BUCKET)

test:
	taskcat test run --input-file ./ci/taskcat.yaml
