# Replace the example AMI with a valid AMI ID for your target region

aws_region            = "eu-west-1"
vpc_cidr              = "10.0.0.0/16"
public_subnet_1_cidr  = "10.0.1.0/24"
public_subnet_2_cidr  = "10.0.2.0/24"
private_subnet_1_cidr = "10.0.3.0/24"
private_subnet_2_cidr = "10.0.4.0/24"
web_ami               = "ami-07952527e23a31a28"
backend_ami           = "ami-00e760e8515f34f32"
instance_type         = "t3.micro"
key_name              = "October2025"