resource "aws_vpc" "primary_vpc" {
  cidr_block           = var.primary_vpc_cidr
  provider             = aws.primary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "Primary-VPC-${var.primary_region}"
    Environment = "Demo"
  }
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block           = var.secondary_vpc_cidr
  provider             = aws.secondary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "Secondary-VPC-${var.secondary_region}"
    Environment = "Demo"
  }
}

resource "aws_security_group" "primary_sg" {
  name     = "primary-vpc-sg"
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP for Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  ingress {
    description = "All traffic from Secondary"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  egress {
    description = "Allow All traffic from Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "Security-group-Primary"
    Environment = "Demo"
  }
}

resource "aws_security_group" "secondary_sg" {
  name     = "secondary-vpc-sg"
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP for Primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  ingress {
    description = "All traffic from Primary"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  egress {
    description = "Allow All traffic from Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "Security-group-Secondary"
    Environment = "Demo"
  }
}

resource "aws_subnet" "primary_subnet" {
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = var.primary_subnet_cidr
  provider                = aws.primary
  availability_zone       = data.aws_availability_zones.primary_zone.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name        = "Primary-Subnet-${var.primary_region}"
    Environment = "Demo"
  }
}

resource "aws_subnet" "secondary_subnet" {
  vpc_id                  = aws_vpc.secondary_vpc.id
  cidr_block              = var.secondary_subnet_cidr
  provider                = aws.secondary
  availability_zone       = data.aws_availability_zones.secondary_zone.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Secondary-Subnet-${var.secondary_region}"
    Environment = "Demo"
  }
}

resource "aws_internet_gateway" "primary_gw" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary
  tags = {
    Name        = "Primary-Internet-Gateway-${var.primary_region}"
    Environment = "Demo"
  }
}

resource "aws_internet_gateway" "secondary_gw" {
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  tags = {
    Name        = "Secondary-Internet-Gateway-${var.secondary_region}"
    Environment = "Demo"
  }
}

resource "aws_route_table" "primary_route_table" {
  vpc_id   = aws_vpc.primary_vpc.id
  provider = aws.primary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_gw.id
  }

  tags = {
    Name        = "Primary-route-table-${var.primary_region}"
    Environment = "Demo"
  }
}
resource "aws_route_table" "secondary_route_table" {
  vpc_id   = aws_vpc.secondary_vpc.id
  provider = aws.secondary

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_gw.id
  }

  tags = {
    Name        = "Secondary-route-table-${var.secondary_region}"
    Environment = "Demo"
  }
}

resource "aws_route_table_association" "primary_association" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_route_table.id
}

resource "aws_route_table_association" "secondary_association" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_route_table.id
}

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider    = aws.primary
  peer_vpc_id = aws_vpc.secondary_vpc.id
  vpc_id      = aws_vpc.primary_vpc.id
  auto_accept = false
  peer_region = var.secondary_region

  tags = {
    Name        = "VPC Peering between Primary and Secondary"
    Environment = "Demo"
    Side        = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "secondary_acceptor" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true

  tags = {
    Name        = "VPC Peering between Secondary and Primary"
    Environment = "Demo"
    Side        = "Sender"
  }
}

resource "aws_route" "primary_r" {
  provider                  = aws.primary
  route_table_id            = aws_route_table.primary_route_table.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary_acceptor]
}

resource "aws_route" "secondary_r" {
  provider                  = aws.secondary
  route_table_id            = aws_route_table.secondary_route_table.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary_acceptor]
}

resource "aws_instance" "primary_instance" {
  provider               = aws.primary
  ami                    = data.aws_ami.primary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = var.primary_key_name

  user_data = local.primary_user_data

  tags = {
    Name        = "Primary-Vpc-Instance"
    Region      = var.primary_region
    Environment = "Demo"
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary_acceptor]
}

resource "aws_instance" "secondary_instance" {
  provider               = aws.secondary
  ami                    = data.aws_ami.secondary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  key_name               = var.secondary_key_name

  user_data = local.secondary_user_data

  tags = {
    Name        = "Secondary-Vpc-Instance"
    Region      = var.secondary_region
    Environment = "Demo"
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary_acceptor]
}
