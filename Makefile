ifndef BRANCH
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
endif
ifeq ($(BRANCH),master)
BUCKET := s3://turbine-quickstart/quickstart-turbine-airflow
else
BUCKET := s3://turbine-quickstart/quickstart-turbine-airflow-$(BRANCH)
endif


lint:
	black . --check
	pylint test/*.py functions/*.py
	cfn-lint templates/*.template

nuke:
	aws-nuke -c ci/awsnuke.yaml --force --quiet --no-dry-run

pack:
	7z a ./functions/package.zip ./functions/*.py

sync: pack
	aws s3 rm $(BUCKET) --recursive
	aws s3 sync --exclude '.*' --acl public-read . $(BUCKET)

test: pack
	pytest -vv
	taskcat test run --input-file ./ci/taskcat.yaml
