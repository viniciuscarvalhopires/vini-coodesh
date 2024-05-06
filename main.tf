resource "aws_vpc" "coodesh_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "coodesh_igw" {
  vpc_id = aws_vpc.coodesh_vpc.id
}

resource "aws_subnet" "coodesh_subnet" {
  vpc_id            = aws_vpc.coodesh_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "igw_route" {
  vpc_id = aws_vpc.coodesh_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.coodesh_igw.id
  }
}

resource "aws_route_table_association" "routetb_subnet_association" {
  subnet_id      = aws_subnet.coodesh_subnet.id
  route_table_id = aws_route_table.igw_route.id
}

resource "aws_security_group" "sg_coodesh" {
  name        = "sg_coodesh"
  description = "Security group NGINX Coodesh"
  vpc_id      = aws_vpc.coodesh_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criar uma instância EC2
resource "aws_instance" "coodesh-nginx" {
  ami             = "ami-0a55ba1c20b74fc30"
  instance_type   = "t4g.micro"
  subnet_id       = aws_subnet.coodesh_subnet.id
  security_groups = [aws_security_group.sg_coodesh.id]
  associate_public_ip_address = false

  depends_on = [aws_security_group.sg_coodesh, aws_subnet.coodesh_subnet]
}

resource "aws_eip" "coodesh_eip" {
  instance = aws_instance.coodesh-nginx.id
}
