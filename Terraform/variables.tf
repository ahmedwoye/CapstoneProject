variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}



variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}



variable "web_ami" {
  description = "AMI for web instances"
  type        = string
  default     = "ami-0d811ba3ed794ec76"
}

variable "backend_ami" {
  description = "AMI for backend instances"
  type        = string
  default     = "ami-00e760e8515f34f32"
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID for instances"
  type        = string
  default     = "vpc-0b703395bdeb8e06d"
}

variable "key_name" {
  description = "EC2 Key Pair name for instances"
  type        = string
  default     = "October2025"
}