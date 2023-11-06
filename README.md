 Deployment of this resources will create the following AWS objects:

- 1 x VPC in AWS
- 1 x Internet Gateway for the the VPC
- 2 x Public Subnets in AZ-A and AZ-B
- 1 x Route Table for the internet and associate them with the subnets
- 1 x Security Group for EC2 Instances with HTTP for ingress and all traffic for egress
- 1 x IAM Instance Profile
- 1 x Launch Configuration for EC2 Instances
- 1 x Autoscaling Group
- 1 x Application Load Balancer
- 1 x Load Balancer Target Group
- 1 x Load Balancer Listeer   

# Pre-Requisites: 

- AWS Account
- IAM user with full Permission to create the above objects from the various services 
- Access Key and Secret for the above User 
- A Linux Machine / VM with Internet Access
- Terraform v1.6.0

# How to Deploy: 

- Clone the Repo 
- Run Terraform init, plan and apply. If no issues this should deploy the services in your AWS account in London Region and will display the loadbalancer DNS address (URL) as an output

# Usage:

- In order to access the Highly Available Webserver with simply visit the Load Balancer DNS URL

# What's under the hood:

- For this demo 2 EC2 instances are are span up  with httpd running behind an application Load Balancer. The Website content is passed as user_data during the build through the launch configuration. It is a simple Hello World website and also was added with a JavaScript widget from the weather website forecast7.com to simulate a data fetch / call from a third party sercvice.
- The location / city of the weather forecast can be changed during build / by changing the code and redeploying.  

# Change Log:
