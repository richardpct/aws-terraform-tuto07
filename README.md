## Purpose

This tutorial takes up the previous one
[aws-terraform-tuto06](https://richardpct.github.io/post/2021/04/05/aws-with-terraform-tutorial-06/)
by adding an ALB (Application Load Balancer) in front of 2 web servers for
sharing the load between multiple  web servers and having almost no downtime
when a web server is failing.

The following figure depicts the infrastructure you will build:

<img src="https://raw.githubusercontent.com/richardpct/images/master/aws-tuto-07/image01.png">

The source code can be found [here](https://github.com/richardpct/aws-terraform-tuto07).

## Configuring the network

#### envs/dev/01-network/main.tf

The following code shows how the subnets are configured:

```
module "network" {
  source                  = "../../../modules/network"
  aws_profile             = var.aws_profile
  region                  = var.region
  env                     = "dev"
  vpc_cidr_block          = "10.0.0.0/16"
  subnet_public_lb        = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  subnet_public_nat       = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  subnet_public_bastion   = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
  subnet_private_web      = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]
  subnet_private_database = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
  cidr_allowed_ssh        = var.my_ip_address
  ssh_public_key          = var.ssh_public_key
}
```

As you can see each service is associated to 3 subnets.<br />
The load balancer, the Nat gateway and the bastion run in the public subnet
whereas the web server and the redis server run in the private subnet.<br />
Comparing the the last tutorial, I moved the web servers from public to private
subnets, because they don't need to be exposed directly to the Internet, instead 
a load balancer is used in front of the web servers.

#### modules/network/main.tf

We create a Nat Gateway in each Availability Zone, the private services (webserver
and redis) located in the AZ-A will use the Nat Gateway in the same AZ-A,
likewise the private services located in the AZ-B will use the Nat Gateway in AZ-B,
and so on..., if a server is located in an unavailable AZ, it will be spin up
in an another healthy AZ.

```
resource "aws_eip" "nat" {
  count  = length(var.subnet_public_nat)
  domain = "vpc"

  tags = {
    Name = "eip_nat-${var.env}-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.subnet_public_nat)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_nat[count.index].id

  tags = {
    Name = "nat_gw-${var.env}-${count.index}"
  }
}
```

I remind you that the public subnets use a default route to the Internet
Gateway whereas the private subnet use a default route to the Nat Gateway:

```
resource "aws_route_table" "route_nat" {
  count  = length(var.subnet_public_nat)
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "default_route-${var.env}-${count.index}"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "custom_route-${var.env}"
  }
}

resource "aws_route_table_association" "public_lb" {
  count          = length(var.subnet_public_lb)
  subnet_id      = aws_subnet.public_lb[count.index].id
  route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "public_nat" {
  count          = length(var.subnet_public_nat)
  subnet_id      = aws_subnet.public_nat[count.index].id
  route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "public_bastion" {
  count          = length(var.subnet_public_bastion)
  subnet_id      = aws_subnet.public_bastion[count.index].id
  route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "private_web" {
  count          = length(var.subnet_private_web)
  subnet_id      = aws_subnet.private_web[count.index].id
  route_table_id = aws_route_table.route_nat[count.index].id
}
```

The Nat Gateway and the bastion still require an Elastic IP, the web servers
don't need it anymore because some publics IP will automatically assign to the
Load Balancer:

```
resource "aws_eip" "nat" {
  count  = length(var.subnet_public_nat)
  domain = "vpc"

  tags = {
    Name = "eip_nat-${var.env}-${count.index}"
  }
}

resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = {
    Name = "eip_bastion-${var.env}"
  }
}
```

## Creating the Load Balancer

#### modules/network/alb.tf

We create our Application Load Balancer assigned in the 3 public subnets:

```
resource "aws_lb" "web" {
  name               = "alb-web-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_web.id]
  subnets            = aws_subnet.public_lb[*].id
}
```

We define the behavior of our Load Balancer: it forwards the requests to the
web servers on port 8000, and check the health of our service by using the test
page located at /cgi-bin/ping.py (you will see later how this script is created),
and the Load Balancer listens the external requests on port 80:

```
resource "aws_lb_target_group" "web" {
  port     = local.web_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/cgi-bin/ping.py"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web.arn
    type             = "forward"
  }
}
```

## Configuring the Web Servers

#### modules/web/main.tf

We create an autoscaling group associated with our Load Balancer to ensure that
we have 2 servers up and running, if a server does not respond correctly on
/cgi-bin/ping.py for any reasons, the load balancer will stop to send the
requests on this failed server, then a new web server will spin up and
replace the failed one.

```
resource "aws_autoscaling_group" "web" {
  name                = "asg_web-${var.env}"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.subnet_private_web_id[*]
  target_group_arns   = [data.terraform_remote_state.network.outputs.alb_target_group_web_arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 2

  launch_template {
    id = aws_launch_template.web.id
  }

  tag {
    key                 = "Name"
    value               = "web-${var.env}"
    propagate_at_launch = true
  }
}
```

#### modules/web/user-data.sh

I added a page located at /cgi-bin/ping.py for checking the health of the web
servers, in addition I display the instance ID for displaying which web server
is responding to the requests:

```
#!/usr/bin/env bash

set -x

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum -y update
sudo yum -y upgrade
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID="$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)"
sudo yum -y install python3-pip
sudo pip install redis
sudo useradd www -s /sbin/nologin
mkdir -p /var/lib/www/cgi-bin

cat << EOF > /var/lib/www/cgi-bin/hello.py
#!/usr/bin/env python3

import redis

r = redis.Redis(
                host='${database_host}',
                port=6379)
r.set('count', 0)
count = r.incr(1)

print("Content-type: text/html")
print("")
print("<html><body>")
print("<p>Hello World!<br />counter: " + str(count) + "<br />env: ${environment}</p>")
print("Id: $INSTANCE_ID")
print("</body></html>")
EOF

cat << EOF > /var/lib/www/cgi-bin/ping.py
#!/usr/bin/env python3

print("Content-type: text/html")
print("")
print("<html><body>")
print("<p>ok</p>")
print("</body></html>")
EOF

chmod 755 /var/lib/www/cgi-bin/hello.py
chmod 755 /var/lib/www/cgi-bin/ping.py
cd /var/lib/www
sudo -u www python3 -m http.server 8000 --cgi
```

## Deploying the infrastructure

Create a file at ~/terraform/aws-terraform-tuto07/terraform_vars_dev_secrets containing:

```
export TF_VAR_aws_profile="dev"
export TF_VAR_region="eu-west-3"
export TF_VAR_bucket="XXX-tofu-state"
export TF_VAR_key_network="tuto-07/dev/network/terraform.tfstate"
export TF_VAR_key_bastion="tuto-07/dev/bastion/terraform.tfstate"
export TF_VAR_key_database="tuto-07/dev/database/terraform.tfstate"
export TF_VAR_key_web="tuto-07/dev/web/terraform.tfstate"
export TF_VAR_ssh_public_key="ssh-ed25519 AAAAXXX"
MY_IP=$(curl -s ifconfig.co/)
export TF_VAR_my_ip_address="$MY_IP/32"
```

Building:

    $ cd envs/dev/01-network
    $ make apply
    $ cd ../02-bastion
    $ make apply
    $ cd ../03-database
    $ make apply
    $ cd ../04-web
    $ terraform apply

## Testing your infrastructure

When your infrastructure is built, you can get the DNS name of your Load Balancer
by performing the following command:

    $ aws --profile dev elbv2 describe-load-balancers --names alb-web-dev \
        --query 'LoadBalancers[*].DNSName' \
        --output text

By using the load balancer DNS name, issue the following command several times
for increasing the counter:

    $ curl http://load_balancer_DNS_NAME/cgi-bin/hello.py

It should return the count of requests you have performed.

## Testing the High Availability

Chose one of the 2 running instances and connect to it, then kill the web
service process:

    $ ssh -J ec2-user@IP_public_bastion ec2-user@IP_private_instance
    $ sudo su -
    # pkill python3

Wait for a while, then the Load Balancer will deregister the unhealthy instance,
you now have only one instance accepting the requests.<br />
If you make some requests to the load balancer, you will notice the service is
still up and running because the Load Balancer has stopped to forward to the
failed server, only the healthy server receives the requests, and also the page
returns the same instance ID (because the other one is out):

    $ curl http://load_balancer_DNS_NAME/cgi-bin/hello.py

Wait for a while, then you will have 2 healthy instances because a new one has
replaced the failed instance, the page will display the 2 instances ID.

## Destroying your infrastructure

After finishing your test, destroy your infrastructure:

    $ cd envs/dev/04-web
    $ make destroy
    $ cd ../03-database
    $ make destroy
    $ cd ../02-bastion
    $ make destroy
    $ cd ../01-network
    $ make destroy

## Summary

In this tutorial I show you how to build an infrastructure in high availability.<br />
In the next tutorial I will show you how to auto scale an infrastructure when
your servers are overloaded.
