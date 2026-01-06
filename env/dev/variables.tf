variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "name_prefix" {
  type    = string
  default = "tf-dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "az" {
  type    = string
  default = "us-east-1a"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "Your laptop public IP in /32, e.g. 98.x.x.x/32"
}
variable "ebs_size_gb" {
  type        = number
  description = "EBS data volume size in GB"
  default     = 10
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    ManagedBy = "Terraform"
  }
}
