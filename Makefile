regions_cmd := aws ec2 describe-regions --query 'Regions[].RegionName | sort_by(@,&@)' --output text
regions_lst := $(shell $(regions_cmd))


lint:
	cfn-lint templates/*.template

test:
	rm -r taskcat_outputs ||:
	taskcat -c ./ci/taskcat.yaml $(TASKCAT_FLAGS)

sync:
	aws s3 cp . s3://villasv/quickstart-turbine-airflow --recursive --acl public-read --exclude '.*'





### other possibly useful commands

purge-taskcat-buckets:
	aws s3 ls | cut -d" " -f 3 | grep taskcat | xargs -I{} \
		aws s3 rm s3://{} --recursive
	aws s3 ls | cut -d" " -f 3 | grep taskcat | xargs -I{} \
		aws s3 rb s3://{}
