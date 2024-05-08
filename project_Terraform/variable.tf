variable "region" {
  description = "The AWS region to create things in."
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_public1" {
  description = "The CIDR block for the first public subnet."
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_public2" {
  description = "The CIDR block for the second public subnet."
  default     = "10.0.2.0/24"
}

variable "ami_id" {
  description = "The AMI to use for the EC2 instances."
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "The type of instance to use for EC2."
  default     = "t2.micro"
}

variable "db_instance_type" {
  description = "The database instance type."
  default     = "db.t2.micro"
}
