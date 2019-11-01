# CHANGELOG

Fork: 31.09.2019
Branch: develop
Contact: olmax99@gmail.com

## Changes in Branch

### 1. Comments

Comments are good, we love comments!!

### 2. Structure

- More granular approach <- easier for debugging
  * external services templates contains database and SQS
  * Security groups have their own template 
- Templates split in `cluster` and `services`

### 3. Delete Buckets

Incident: DELETE_FAILED with Logs and Deployment Bucket are not empty

- Added custom cfn event + Lambda function for cleaning deployments bucket contents when delete-stack
- Retain Logs bucket for error investigation or dag data archiving




 