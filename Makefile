
lint:
	cfn-lint templates/*.template

test:
	rm -r taskcat_outputs ||:
	taskcat -c ./ci/taskcat.yaml $(TASKCAT_FLAGS)

sync:
	aws s3 sync . s3://villasv/quickstart-turbine-airflow --acl public-read --exclude '.*'

sync-dev:
	aws s3 sync . s3://villasv/quickstart-turbine-airflow-dev --acl public-read --exclude '.*'
