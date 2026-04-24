output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_public_bastion_id" {
  value = aws_subnet.public_bastion[*].id
}

output "subnet_private_database_id" {
  value = aws_subnet.private_database[*].id
}

output "subnet_private_web_id" {
  value = aws_subnet.private_web[*].id
}

output "sg_bastion_id" {
  value = aws_security_group.bastion.id
}

output "sg_database_id" {
  value = aws_security_group.database.id
}

output "sg_web_id" {
  value = aws_security_group.web.id
}

output "aws_eip_bastion_id" {
  value = aws_eip.bastion.id
}

output "aws_eip_bastion_ip" {
  value = aws_eip.bastion.public_ip
}

output "alb_target_group_web_arn" {
  value = aws_lb_target_group.web.arn
}

output "alb_web_dns" {
  value = aws_lb.web.dns_name
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.profile.name
}

output "ssh_key" {
  value = aws_key_pair.deployer.key_name
}
