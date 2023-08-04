## This is the base configuration for the AWS provider
## A more robust configuration is being used in the main.tf file

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

## https://medium.com/@hmalgewatta/setting-up-an-aws-ec2-instance-with-ssh-access-using-terraform-c336c812322f
resource "aws_vpc" "club_devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "club-devops-vpc"
  }
}

resource "aws_eip" "club_devops_eip" {
  domain     = "vpc"
  instance   = aws_instance.clubdevops.id
  depends_on = [aws_internet_gateway.club_devops_gateway]

  tags = {
    Name = "club-devops-eip"
  }
}

resource "aws_eip_association" "club_devops_eip_association" {
  instance_id   = aws_instance.clubdevops.id
  allocation_id = aws_eip.club_devops_eip.id
  depends_on    = [aws_eip.club_devops_eip]
}

resource "aws_internet_gateway" "club_devops_gateway" {
  vpc_id = aws_vpc.club_devops_vpc.id

  tags = {
    Name = "club-devops-gateway"
  }
}

resource "aws_security_group" "ingress-all" {

  name        = "allow-all-sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.club_devops_vpc.id

  // For everyone to access the web server
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    // Here you can specify the IP range you want to allow, in this case it is open to the world since it is a web server
    // If not we would use my IP address and the IP address of the other developers
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To allow SSH access to the web server
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // This means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_network_interface" "club_devops_network_interface" {
  subnet_id       = aws_subnet.subnet_base.id
  security_groups = [aws_security_group.ingress-all.id]
}

resource "aws_subnet" "subnet_base" {
  cidr_block        = cidrsubnet(aws_vpc.club_devops_vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.club_devops_vpc.id
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "route_table_base" {
  vpc_id = aws_vpc.club_devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.club_devops_gateway.id
  }

  tags = {
    Name = "club-devops-route-table"
  }
}

resource "aws_route_table_association" "route_table_association_base" {
  subnet_id      = aws_subnet.subnet_base.id
  route_table_id = aws_route_table.route_table_base.id
}

resource "aws_instance" "clubdevops" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet_base.id
  vpc_security_group_ids      = [aws_security_group.ingress-all.id]
  key_name                    = aws_key_pair.ssh_key.key_name


  tags = {
    Name = var.instance_name
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "club-devops-key"
  public_key = file("~/.ssh/club-devops-key.pub")
}


resource "aws_iam_group" "administrators" {
  name = var.admin_group_name
  path = var.admin_group_path
}

resource "aws_iam_group" "members" {
  name = var.member_group_name
  path = var.member_group_path
}

resource "aws_iam_group" "guests" {
  name = var.guest_group_name
  path = var.guest_group_path
}

resource "aws_iam_policy" "administrators_access" {
  name        = "AdministratorsAccess"
  path        = var.admin_group_path
  description = var.admin_group_policy_description

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
  path        = var.member_group_path
  description = var.member_group_policy_description

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
  name        = "GuestsAccess"
  path        = var.admin_group_path
  description = var.guest_group_policy_description

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

resource "aws_iam_group_policy_attachment" "administrators-attach" {
  group      = aws_iam_group.administrators.name
  policy_arn = aws_iam_policy.administrators_access.arn
}

resource "aws_iam_group_policy_attachment" "members-attach" {
  group      = aws_iam_group.members.name
  policy_arn = aws_iam_policy.members_access.arn
}

resource "aws_iam_group_policy_attachment" "guests-attach" {
  group      = aws_iam_group.guests.name
  policy_arn = aws_iam_policy.guests_access.arn
}

resource "aws_iam_user" "administrator" {
  name = var.admin_group_name
}

resource "aws_iam_user" "members" {
  name = var.member_group_name
}

resource "aws_iam_user" "guest" {
  name = var.guest_group_name
}

resource "aws_iam_user_group_membership" "admin" {
  user   = aws_iam_user.administrator.name
  groups = [aws_iam_group.administrators.name]
}

resource "aws_iam_user_group_membership" "member" {
  user   = aws_iam_user.members.name
  groups = [aws_iam_group.members.name]
}

resource "aws_iam_user_group_membership" "guest" {
  user   = aws_iam_user.guest.name
  groups = [aws_iam_group.guests.name]
}

resource "aws_iam_user_login_profile" "member" {
  user                    = aws_iam_user.members.name
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
