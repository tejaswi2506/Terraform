variable "name_prefix" {
  type        = string
  description = "Prefix for naming EBS volume (e.g., tf-prod-lab-dev)"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone where the EBS volume will be created (must match EC2 AZ)"
}

variable "instance_id" {
  type        = string
  description = "EC2 instance ID to which the EBS volume will be attached"
}

variable "size_gb" {
  type        = number
  description = "Size of the EBS data volume in GB"
  default     = 10
}

variable "volume_type" {
  type        = string
  description = "EBS volume type"
  default     = "gp3"
}

variable "encrypted" {
  type        = bool
  description = "Whether the EBS volume should be encrypted"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the EBS volume"
  default     = {}
}
