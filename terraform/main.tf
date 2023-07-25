terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_instance" "clubdevops" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}

resource "aws_iam_group" "administrators" {
  name = "Administrators"
  path = "/club-devops"
}

resource "aws_iam_group" "members" {
  name = "Members"
  path = "/club-devops"
}

resource "aws_iam_group" "guests" {
  name = "Guest"
  path = "/club-devops"
}

resource "aws_iam_policy" "administrators_access" {
  name        = "AdministratorsAccess"
  path        = "/club-devops"
  description = "DevOps club administrators access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "members_access" {
  name        = "MembersAccess"
  path        = "/club-devops"
  description = "DevOps club members access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*",
          "ec2:CreateKeypair",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "guests_access" {
  name        = "GuestAccess"
  path        = "/club-devops"
  description = "Outside members access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:List*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "administrators" {
  group      = aws_iam_group.administrators.name
  policy_arn = aws_iam_group.administrators.arn
}

resource "aws_iam_group_policy_attachment" "members" {
  group      = aws_iam_group.members.name
  policy_arn = aws_iam_group.members.arn
}

resource "aws_iam_group_policy_attachment" "guests" {
  group      = aws_iam_group.guests.name
  policy_arn = aws_iam_group.guests.arn
}

resource "aws_iam_user" "administrator" {
  name = "Administrator"
}

resource "aws_iam_user" "members" {
  name = "Members"
}

resource "aws_iam_user" "guest" {
  name = "Guest"
}

resource "aws_iam_user_group_membership" "devops_unlp" {
  user   = aws_iam_user.administrator.name
  groups = [aws_iam_group.administrators.name, aws_iam_group.members.name, aws_iam_group.guests.name]
}

resource "aws_iam_user_login_profile" "administrator" {
  user                    = aws_iam_user.administrator.name
  password_length         = 20
  password_reset_required = true
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 10
  max_password_age               = 90
  password_reuse_prevention      = 3
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
}
