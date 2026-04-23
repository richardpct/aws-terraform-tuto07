locals {
  ssh_port       = 22
  http_port      = 80
  https_port     = 443
  redis_port     = 6379
  web_port       = 8000
  anywhere       = ["0.0.0.0/0"]
}

variable "aws_profile" {
  type        = string
  description = "aws profile"
}

variable "region" {
  type        = string
  description = "region"
}

variable "env" {
  type        = string
  description = "environment"
}

variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block"
}

variable "subnet_public_lb" {
  type        = list(string)
  description = "public alb subnet"
}

variable "subnet_public_nat" {
  type        = list(string)
  description = "public nat gateway subnet"
}

variable "subnet_public_bastion" {
  type        = list(string)
  description = "public bastion subnet"
}

variable "subnet_private_database" {
  type        = list(string)
  description = "private database subnet"
}

variable "subnet_private_web" {
  type        = list(string)
  description = "private web subnet"
}

variable "cidr_allowed_ssh" {
  type        = string
  description = "cidr block allowed to connect through ssh" 
}

variable "ssh_public_key" {
  type        = string
  description = "ssh public key"
}
