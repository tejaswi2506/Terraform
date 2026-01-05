variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_id" { type = string }

variable "instance_type" { type = string }
variable "ami_id" { type = string }
variable "key_name" { type = string }

variable "ssh_allowed_cidr" { type = string }

variable "user_data" {
  type        = string
  description = "Cloud-init user-data script"
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}