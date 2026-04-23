data "aws_availability_zones" "available" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "my_vpc-${var.env}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw-${var.env}"
  }
}

resource "aws_subnet" "public_lb" {
  count             = length(var.subnet_public_lb)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_public_lb[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_public_lb-${var.env}-${count.index}"
  }
}

resource "aws_subnet" "public_nat" {
  count             = length(var.subnet_public_nat)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_public_nat[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_public_nat-${var.env}-${count.index}"
  }
}

resource "aws_subnet" "public_bastion" {
  count             = length(var.subnet_public_bastion)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_public_bastion[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_public_bastion-${var.env}-${count.index}"
  }
}

resource "aws_subnet" "private_web" {
  count             = length(var.subnet_private_web)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_private_web[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_private_web-${var.env}-${count.index}"
  }
}

resource "aws_subnet" "private_database" {
  count             = length(var.subnet_private_database)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_private_database[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_private_database-${var.env}-${count.index}"
  }
}

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

resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = {
    Name = "eip_bastion-${var.env}"
  }
}
