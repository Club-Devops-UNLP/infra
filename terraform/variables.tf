############## AWS ##############

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Club Devops UNLP"
}

variable "instance_type" {
  description = "Type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "instance_ami" {
  description = "AMI to use for the EC2 instance"
  type        = string
  default     = "ami-053b0d53c279acc90" # Verify this once a while
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "secret_key" {
  description = "Secret key for the AWS access key"
  type        = string
  default     = ""
  sensitive   = true
}

