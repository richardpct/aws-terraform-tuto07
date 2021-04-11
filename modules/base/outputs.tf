output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_public_a_id" {
  value = aws_subnet.public_a.id
}

output "subnet_public_b_id" {
  value = aws_subnet.public_b.id
}

output "subnet_private_id" {
  value = aws_subnet.private.id
}

output "sg_bastion_id" {
  value = aws_security_group.bastion.id
}

output "sg_database_id" {
  value = aws_security_group.database.id
}

output "sg_webserver_id" {
  value = aws_security_group.webserver.id
}

output "aws_eip_bastion_id" {
  value = aws_eip.bastion.id
}

#output "aws_eip_web_id" {
#  value = aws_eip.web.id
#}

output "alb_target_group_web_arn" {
  value = aws_lb_target_group.web.arn
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.profile.name
}

output "ssh_key" {
  value = aws_key_pair.deployer.key_name
}
