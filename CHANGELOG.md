# CHANGELOG

Fork: 31.09.2019
Branch: develop
Contact: olmighty99@gmail.com

## Changes in Branch Develop

### 1. Comments

- Comments are good, we love comments!!

### 2. Structure

- More granular templates folder <- easier for maintaining and debugging
  * `turbine-resource.template` contains all the Turbine support services
  * The security groups have a dedicated template
  * CI has its own sub folder
- Templates split in `cluster`, `services`, and `ci`

### 3. Log and Deployment Bucket

- Private Buckets by default (explicit)

Incident: After dag run, CloudFormation DELETE_FAILED with "Logs and Deployment 
Bucket are not empty"

- Added custom Cfn event + Lambda function for cleaning deployments bucket 
content when delete-stack
- Retain Logs bucket for error investigation or dag data archiving




 