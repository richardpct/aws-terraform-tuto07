provider "aws" {
  region = var.region
}

data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket = var.base_remote_state_bucket
    key    = var.base_remote_state_key
    region = var.region
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = var.database_remote_state_bucket
    key    = var.database_remote_state_key
    region = var.region
  }
}

#data "aws_availability_zones" "available" {}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    environment   = var.env
    database_host = data.terraform_remote_state.database.outputs.database_private_ip
  }
}

resource "aws_launch_configuration" "web" {
  name                        = "webserver-${var.env}"
  image_id                    = var.image_id
  user_data                   = data.template_file.user_data.rendered
  instance_type               = var.instance_type
  key_name                    = data.terraform_remote_state.base.outputs.ssh_key
  security_groups             = [data.terraform_remote_state.base.outputs.sg_webserver_id]
  iam_instance_profile        = data.terraform_remote_state.base.outputs.iam_instance_profile_name
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "asg_web-${var.env}"
  launch_configuration = aws_launch_configuration.web.id
  vpc_zone_identifier  = [data.terraform_remote_state.base.outputs.subnet_private_web_a_id, data.terraform_remote_state.base.outputs.subnet_private_web_b_id]
  target_group_arns    = [data.terraform_remote_state.base.outputs.alb_target_group_web_arn]
  health_check_type    = "ELB"

  min_size             = 2
  max_size             = 2

  tag {
    key                 = "Name"
    value               = "webserver-${var.env}"
    propagate_at_launch = true
  }
}
