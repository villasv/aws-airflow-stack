regions_cmd := aws ec2 describe-regions --query 'Regions[].RegionName | sort_by(@,&@)' --output text
regions_lst := $(shell $(regions_cmd))


test:
	taskcat -c ./ci/taskcat.yaml

sync:
	aws s3 sync ./templates s3://villasv/turbine/templates --acl public-read





### other possibly useful commands

purge-taskcat-buckets:
	aws s3 ls | cut -d" " -f 3 | grep taskcat | xargs -I{} \
		aws s3 rm s3://{} --recursive
	aws s3 ls | cut -d" " -f 3 | grep taskcat | xargs -I{} \
		aws s3 rb s3://{}
