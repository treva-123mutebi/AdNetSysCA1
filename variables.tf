variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of SG IDs to attach"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the EC2 keypair"
  type        = string
}

variable "app_source_url" {
  description = "URL to download index.html"
  type        = string
  default     = "https://raw.githubusercontent.com/treva-123mutebi/awsterraform/main/index.html"
}

variable "docker_host_tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
  default     = {
    Name = "DockerHost"
  }
}
