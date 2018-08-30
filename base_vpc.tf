resource "aws_vpc" "vpc" {
  cidr_block                       = "10.1.1.0/24"
  assign_generated_ipv6_cidr_block = "false"
  enable_dns_support               = "true"
  enable_dns_hostnames             = "true"

  tags {
    "Name"  = "swarm-lab-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    "Name"  = "swarm-lab-igw"
  }
}

resource "aws_subnet" "admin" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.1.0/25"
  map_public_ip_on_launch  = "true"

  tags {
    Name = "swarm-lab-admin"
  }
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    "Name"  = "swarm-lab-rt"
  }
}

resource "aws_route_table_association" "admin-rt-association" {
  subnet_id      = "${aws_subnet.admin.id}"
  route_table_id = "${aws_route_table.external.id}"
}


/* Default security group */
resource "aws_security_group" "swarm" {
  name = "swarm-group"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["64.215.115.131/32"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags { 
    Name = "swarm-example" 
  }
}