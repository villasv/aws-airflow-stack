# CHANGELOG

Fork: 31.09.2019
Branch: develop
Contact: olmax99@gmail.com

## Changes in Branch

### 1. Comments

Comments are good, we love comments!!

### 2. Structure

- More granular approach <- easier for maintaining and debugging
  * external services templates contains database and SQS
  * All security groups have a dedicated template 
- Templates split in `cluster` and `services`

### 3. Log and Deployment Bucket

Incident: After dag run, cloudformation DELETE_FAILED with "Logs and Deployment 
Bucket are not empty"

- Private Buckets by default
- Added custom Cfn event + Lambda function for cleaning deployments bucket 
content when delete-stack
- Retain Logs bucket for error investigation or dag data archiving




 