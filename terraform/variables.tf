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

variable "aws_key_pair_name" {
  description = "Name of the AWS key pair to create"
  type        = string
  default     = "member-key"
}

variable "aws_key_pair_public_key" {
  description = "Path to store the AWS key pair"
  type        = string
  default     = ""
  sensitive   = true
}

############## IAM ##############

variable "admin_group_name" {
  description = "Name of the admin group"
  type        = string
  default     = "Administrators"
}

variable "admin_group_path" {
  description = "Path for the admin group"
  type        = string
  default     = "/"
}

variable "admin_group_policy_description" {
  description = "Description for the admin group policy"
  type        = string
  default     = "Administrators have full access to EC2 resources"
}

variable "member_group_name" {
  description = "Name of the member group"
  type        = string
  default     = "Members"
}

variable "member_group_path" {
  description = "Path for the member group"
  type        = string
  default     = "/"
}

variable "member_group_policy_description" {
  description = "Description for the member group policy"
  type        = string
  default     = "Members have access EC2 resources"
}

variable "guest_group_name" {
  description = "Name of the guest group"
  type        = string
  default     = "Guests"
}

variable "guest_group_path" {
  description = "Path for the guest group"
  type        = string
  default     = "/"
}

variable "guest_group_policy_description" {
  description = "Description for the guest group policy"
  type        = string
  default     = "Guests have read-only access to all resources"
}

############## AZURE ##############

variable "prefix" {
  default = "cvu"
}

variable "subscription_id" {
  default     = ""
  sensitive   = true
  description = "Azure Subscription ID"
}

variable "client_id" {
  default     = ""
  sensitive   = true
  description = "Azure Client ID"
}

variable "client_secret" {
  default     = ""
  sensitive   = true
  description = "Azure Client Secret"
}

variable "tenant_id" {
  default     = ""
  sensitive   = true
  description = "Azure Tenant ID"
}

variable "azure_key_pair_public_key" {
  description = "Path to store the Azure key pair"
  type        = string
  default     = ""
  sensitive   = true
}
