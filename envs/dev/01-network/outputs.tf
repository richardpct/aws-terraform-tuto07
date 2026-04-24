output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_public_bastion_id" {
  value = module.network.subnet_public_bastion_id
}

output "subnet_private_database_id" {
  value = module.network.subnet_private_database_id
}

output "subnet_private_web_id" {
  value = module.network.subnet_private_web_id
}

output "sg_bastion_id" {
  value = module.network.sg_bastion_id
}

output "sg_database_id" {
  value = module.network.sg_database_id
}

output "sg_web_id" {
  value = module.network.sg_web_id
}

output "aws_eip_bastion_id" {
  value = module.network.aws_eip_bastion_id
}

output "aws_eip_bastion_ip" {
  value = module.network.aws_eip_bastion_ip
}

output "alb_target_group_web_arn" {
  value = module.network.alb_target_group_web_arn
}

output "alb_web_dns" {
  value = module.network.alb_web_dns
}

output "iam_instance_profile_name" {
  value = module.network.iam_instance_profile_name
}

output "ssh_key" {
  value = module.network.ssh_key
}
