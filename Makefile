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

test:
	taskcat -c ./ci/taskcat.yaml

sync:
	aws s3 sync --exclude '.*' --acl public-read . $(BUCKET)
