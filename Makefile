

sync:
	aws s3 sync ./templates s3://villasv/turbine/templates --acl public-read
