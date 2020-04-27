prefix := quickstart-turbine-airflow
bucket := s3://turbine-quickstart

ifndef branch
branch := $(shell git rev-parse --abbrev-ref HEAD)
endif
ifneq ($(branch),master)
prefix := $(prefix)-$(branch)
endif

regions := $(shell yq -r '.Mappings.AWSAMIRegionMap | keys[]' \
	templates/turbine-scheduler.template)


lint:
	black . --check
	flake8 .
	pylint **/*.py
	cfn-lint templates/*.template

nuke:
	aws-nuke -c ci/awsnuke.yaml --force --quiet --no-dry-run

pack:
	7z a ./functions/package.zip ./functions/*.py -stl

s3-%: pack
	aws s3 sync --delete --exclude '.*' --acl public-read . $(bucket)-$*/$(prefix)

targets := $(addprefix s3-,$(regions))
sync: pack $(targets)
	aws s3 sync --delete --exclude '.*' --acl public-read . $(bucket)/$(prefix)

test: pack
	pytest -vv
	taskcat test run --input-file ./ci/taskcat.yaml
