# Purpose
This tutorial takes up the previous one
[https://github.com/richardpct/aws-terraform-tuto06](https://github.com/richardpct/aws-terraform-tuto06)
by adding an ALB (application load balancer) in front of 2 webservers to have a
fault tolerance.

Here are the components you will build:

* Creating a VPC with 2 publics subnets (each in different availability zone)
and a private subnet
* Creating a bastion server with autoscaling group associated to the two publics
subnets which is the only server that can be reachable from the Internet through
SSH, and it is the only that is allowed to connect to the database and the
webserver through SSH
* Creating 2 webservers with autoscaling group associated to the two publics
subnets.  
For this example I wrote a Go
[program](https://github.com/richardpct/go-example-tuto04) which spins up a
webserver
* Creating an ALB (Application Load Balancer) in front of the 2 webservers, if
a webserver failed, the load balancer will stop sending the requests to it
* Creating a database server in the private subnet using Redis which stores the
count of requests, only the webserver is allowed to send requests to the
database
* Creating a NAT gateway associated to an Elastic IP (EIP) so that the database
which is in the private subnet can reach Internet
* Adding an IAM role that allows an EC2 instance to attach an EIP

Notice: For this example I do not use "Elastic Cache" feature provided by AWS,
instead I use an EC2 instance and I install manually Redis

# Requirement
* You must have an AWS account, if you don't have yet, you can subscribe to the
free tier.
* You must install terraform

# Usage
## Exporting the required variables in your terminal:
    $ export TF_VAR_region="eu-west-3"
    $ export TF_VAR_bucket="my-terraform-state"
    $ export TF_VAR_dev_base_key="terraform/dev/base/terraform.tfstate"
    $ export TF_VAR_dev_bastion_key="terraform/dev/bastion/terraform.tfstate"
    $ export TF_VAR_dev_database_key="terraform/dev/database/terraform.tfstate"
    $ export TF_VAR_dev_webserver_key="terraform/dev/webserver/terraform.tfstate"
    $ export TF_VAR_ssh_public_key="ssh-rsa ..."
    $ export TF_VAR_dev_database_pass="redispasswd"
    $ export TF_VAR_my_ip_address=xx.xx.xx.xx/32

## Creating the S3 backend for storing the terraform state if it is not already done
If you have not created a S3 backend, follow my first tutorial
[https://github.com/richardpct/aws-terraform-tuto01](https://github.com/richardpct/aws-terraform-tuto01)

## Creating the VPC, subnet and security group
    $ cd environment/dev/00-base
    $ ./terraform_init.sh (issue this command once)
    $ terraform apply

## Creating the bastion
    $ cd ../01-bastion
    $ ./terraform_init.sh (issue this command once)
    $ terraform apply

## Creating the database
    $ cd ../02-database
    $ ./terraform_init.sh (issue this command once)
    $ terraform apply

## Creating the webserver
    $ cd ../03-webserver
    $ ./terraform_init.sh (issue this command once)
    $ terraform apply

## Testing your page
Open your web browser by using the public IP address of your webserver that is
displayed previously

## Connecting to the database and the webserver through SSH
    $ ssh -J ubuntu@public_ip_bastion ubuntu@private_ip_database
    $ ssh -J ubuntu@public_ip_bastion ubuntu@private_ip_webserver

## Testing the fault tolerance
Open your aws console then terminate a webserver instance, as you can see your
service is still available

## Creating the staging environment
Repeat the same steps as previously by using the staging directory instead the
dev directory

## Cleaning up
Choose your environment by entering in dev, staging or prod directory

    $ cd ../03-webserver
    $ terraform destroy
    $ cd ../02-database
    $ terraform destroy
    $ cd ../01-bastion
    $ terraform destroy
    $ cd ../00-base
    $ terraform destroy
