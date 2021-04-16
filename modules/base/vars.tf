locals {
  ssh_port       = 22
  http_port      = 80
  https_port     = 443
  redis_port     = 6379
  webserver_port = 8000
  anywhere       = ["0.0.0.0/0"]
}

variable "region" {
  description = "region"
}

variable "env" {
  description = "environment"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}

variable "subnet_public_lb_a" {
  description = "public ALB subnet A"
}

variable "subnet_public_lb_b" {
  description = "public ALB subnet B"
}

variable "subnet_public_nat_a" {
  description = "public NAT GW subnet A"
}

variable "subnet_public_nat_b" {
  description = "public NAT GW subnet B"
}

variable "subnet_public_bastion_a" {
  description = "public bastion subnet A"
}

variable "subnet_public_bastion_b" {
  description = "public bastion subnet B"
}

variable "subnet_private_web_a" {
  description = "private web subnet A"
}

variable "subnet_private_web_b" {
  description = "private web subnet B"
}

variable "subnet_private_redis_a" {
  description = "private redis subnet A"
}

variable "subnet_private_redis_b" {
  description = "private redis subnet B"
}

variable "cidr_allowed_ssh" {
  description = "cidr block allowed to connect through SSH"
}

variable "ssh_public_key" {
  description = "ssh public key"
}
