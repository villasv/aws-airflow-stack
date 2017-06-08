## Init

 If your script did not accomplish the tasks you were expecting it to, or if you just want to verify that your script completed without errors, examine the cloud-init output log file at /var/log/cloud-init-output.log and look for error messages in the output. 

## Steps to Enable SSH

SSH connectivity is not enabled by default because this template tries to achieve production readyness and this is too particular for each environment to chose a one-size-fits-all approach.

At Gupy we use VPN on top of SSH, but for the sake of simplicity and completeness here we have the steps to open SSH with public access (restricted by the private key).

1. Create an Internet Gateway
2. Assign Public IPs
3. Add Route for Subnet