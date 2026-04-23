# rules for bastion
resource "aws_security_group" "bastion" {
  name   = "sg_bastion-${var.env}"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "bastion_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "bastion_from_me_ssh" {
  type              = "ingress"
  from_port         = local.ssh_port
  to_port           = local.ssh_port
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_allowed_ssh]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_to_web_ssh" {
  type                     = "egress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_to_any_http" {
  type              = "egress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = "tcp"
  cidr_blocks       = local.anywhere
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_to_any_https" {
  type              = "egress"
  from_port         = local.https_port
  to_port           = local.https_port
  protocol          = "tcp"
  cidr_blocks       = local.anywhere
  security_group_id = aws_security_group.bastion.id
}

# rules for database
resource "aws_security_group" "database" {
  name   = "sg_database-${var.env}"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "database_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "db_from_web_redis" {
  type                     = "ingress"
  from_port                = local.redis_port
  to_port                  = local.redis_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.database.id
}

# rules for alb web
resource "aws_security_group" "alb_web" {
  name   = "sg_alb_web-${var.env}"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "alb_web_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "alb_web_from_any_http" {
  type              = "ingress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = "tcp"
  cidr_blocks       = local.anywhere
  security_group_id = aws_security_group.alb_web.id
}

resource "aws_security_group_rule" "alb_web_to_web_http" {
  type                     = "egress"
  from_port                = local.web_port
  to_port                  = local.web_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.alb_web.id
}

# rules for webserver
resource "aws_security_group" "web" {
  name   = "sg_web-${var.env}"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "web_sg-${var.env}"
  }
}

resource "aws_security_group_rule" "web_from_bastion_ssh" {
  type                     = "ingress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_from_alb_web_http" {
  type                     = "ingress"
  from_port                = local.web_port
  to_port                  = local.web_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_web.id
  security_group_id        = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_to_any_http" {
  type              = "egress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = "tcp"
  cidr_blocks       = local.anywhere
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_to_any_https" {
  type              = "egress"
  from_port         = local.https_port
  to_port           = local.https_port
  protocol          = "tcp"
  cidr_blocks       = local.anywhere
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_to_db_redis" {
  type                     = "egress"
  from_port                = local.redis_port
  to_port                  = local.redis_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.database.id
  security_group_id        = aws_security_group.web.id
}
