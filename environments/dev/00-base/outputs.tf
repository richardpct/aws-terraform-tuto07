output "vpc_id" {
  value = module.base.vpc_id
}

#output "subnet_public_lb_a_id" {
#  value = module.base.subnet_public_lb_a_id
#}
#
#output "subnet_public_lb_b_id" {
#  value = module.base.subnet_public_lb_b_id
#}

output "subnet_public_bastion_a_id" {
  value = module.base.subnet_public_bastion_a_id
}

output "subnet_public_bastion_b_id" {
  value = module.base.subnet_public_bastion_b_id
}

output "subnet_private_web_a_id" {
  value = module.base.subnet_private_web_a_id
}

output "subnet_private_web_b_id" {
  value = module.base.subnet_private_web_b_id
}

output "subnet_private_redis_a_id" {
  value = module.base.subnet_private_redis_a_id
}

output "subnet_private_redis_b_id" {
  value = module.base.subnet_private_redis_b_id
}

output "sg_bastion_id" {
  value = module.base.sg_bastion_id
}

output "sg_database_id" {
  value = module.base.sg_database_id
}

output "sg_webserver_id" {
  value = module.base.sg_webserver_id
}

output "aws_eip_bastion_id" {
  value = module.base.aws_eip_bastion_id
}

output "alb_target_group_web_arn" {
  value = module.base.alb_target_group_web_arn
}

output "iam_instance_profile_name" {
  value = module.base.iam_instance_profile_name
}

output "ssh_key" {
  value = module.base.ssh_key
}
