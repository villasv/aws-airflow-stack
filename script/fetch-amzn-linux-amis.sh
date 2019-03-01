#!/bin/sh

regions=$(aws ec2 describe-regions --query "Regions[].RegionName | sort_by(@,&@)" --output text)
for region in $regions
do
    ami=$(aws --region $region ec2 describe-images \
        --filters "Name=name,Values=amzn2-ami-hvm-2.0.20180622.1-x86_64-gp2" \
        --query "Images[0].ImageId" --output "text")
    printf "    $region:\n      HVMGP2: $ami\n"
done
