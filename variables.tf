variable "region" {
  description = "The AWS region to create resources in"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "custom_ami_id" {
  description = "ID of your custom AMI"
  type        = string
}

variable "application_port" {
  description = "Port on which your application runs"
  type        = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}


variable "allow_ssh_from" {
  description = "Allow ssh from"
  type        = string
}

variable "db_password" {
  type        = string
  description = "Password for the RDS instance"
  sensitive   = true
}


variable "db_port" {
  type        = string
  description = "port for the RDS instance"
  sensitive   = true
}

variable "domain_name" {
  type        = string
  description = "Your domain name (e.g., example.com)"
}