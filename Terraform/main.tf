terraform {
  backend "s3" {
    bucket  = "teachbleat-cicd-state-bucket"
    key     = "envs/dev/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- 1. WEB INSTANCES (Public) ---
resource "aws_instance" "Bastion" {
 
  ami                         = var.web_ami
  instance_type               = var.instance_type
  subnet_id                   =  aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

   tags = { Name = "Bastion" }
   
}

# --- 2. BACKEND INSTANCES (Private) ---
resource "aws_instance" "ApplicationService" {

  ami                    = var.backend_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_1.id 
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = false

  tags = { Name = "ApplicationService" }
}

 


# --- 4. DATABASE RESOURCES ---



resource "aws_db_subnet_group" "project_db_subnet_group" {
  name       = "project-db-subnet-group-${aws_vpc.project_network.id}"

  subnet_ids = [
    aws_subnet.private_subnet_1.id
   
  ]

  tags = {
    Name = "Project DB Subnet Group"
  }
}


# The Database Instance
resource "aws_db_instance" "project_db" {
  identifier           = "project-database"
  engine               = "postgres"
  instance_class       = "db.t4g.micro"
  allocated_storage    = 20
  username             = "postgres"
  password             = "olasumbo" 
  
  db_subnet_group_name = aws_db_subnet_group.project_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  skip_final_snapshot  = true
  publicly_accessible  = false
}




# -------------------------------
#  Security Groups
# -------------------------------
# Public Web SG
resource "aws_security_group" "Bastion" {
  name   = "web-sg"
  vpc_id = aws_vpc.project_network.id

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


# Backend SG (private)
resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = aws_vpc.project_network.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]  # Jenkins access
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]      # Web app access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database SG (private)
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow backend access"
  vpc_id      = aws_vpc.project_network.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}