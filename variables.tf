# Region & naming
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for naming and tagging resources"
  type        = string
  default     = "bo-autoheal"
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs across availability zones"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Access
variable "allowed_ssh_cidr_block" {
  description = "Optional admin SSH CIDR (e.g. 203.0.113.5/32). Leave empty to disable."
  type        = string
  default     = ""
}

# Compute / ASG
variable "instance_type" {
  description = "EC2 instance type for ASG instances"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Min ASG size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Max ASG size"
  type        = number
  default     = 4
}
