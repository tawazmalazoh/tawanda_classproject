provider "aws" {
  region = var.region
}


# creatinf VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# creating Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}


# creating  SUBNET 1
resource "aws_subnet" "public123" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_public1
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
}

# SUBNET 2
resource "aws_subnet" "public234" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_public2
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"
}


# Route table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


# Association of subnets with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public123.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public234.id
  route_table_id = aws_route_table.public.id
}


# SG Groups- EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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


# SG Groups- ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
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

## SG Groups- Database
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 3306
    to_port     = 3306
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


# AUTO SCALING ISSUES
resource "aws_launch_configuration" "asg_config" {
  name            = "ASG-Config"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ec2_sg.id]
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.asg_config.id
  min_size             = 2
  max_size             = 10
  vpc_zone_identifier  = [aws_subnet.public123.id, aws_subnet.public234.id]
}



#ALB
resource "aws_lb" "lbtawazmain" {
  name               = "lbtawazmain"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public123.id, aws_subnet.public234.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lbtawazmain.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}



#S3 bucket
resource "aws_s3_bucket" "btaws123" {
  bucket = "btaws123"

}





# lAM roles
resource "aws_iam_role" "Tawaz_role" {
  name = "Tawaz_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# lAM Policy
resource "aws_iam_role_policy" "ec2_policy" {
  role = aws_iam_role.Tawaz_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}



# Database
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.public123.id, aws_subnet.public234.id]
  
}


resource "aws_db_instance" "tawazdb" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "tawazmalazoh123"
  password             = "teeoneMalazoh123"
  skip_final_snapshot  = true
}
