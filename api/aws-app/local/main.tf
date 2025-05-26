terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48"
    }
  }

  required_version = ">= 0.15.0"
}

provider "aws" {
  profile = "gh-actions"
  region  = "eu-west-1"
}

variable "sample_public_key" {
  description = "Sample environment public key value"
  type        = string
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "sample_key" {
  key_name   = "sample-key"
  public_key = var.sample_public_key

  tags = {
    "Name" = "sample_public_key"
  }
}

resource "aws_instance" "sample_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0b1a8249c6307592d"]
  key_name               = aws_key_pair.sample_key.key_name

  tags = {
    "Name" = "dotnetwebapi"
  }
  site_config {
    # site_config options: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app#always_on
    always_on = false # must be false for F1 (free)

    # legacy app_service used linux_fx_version: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service#linux_fx_version
    #   i.e. linux_fx_version = "DOCKER|dockerbot93/actions-web-test:latest"
    #   use application_stack instead:
    application_stack {
      docker_image_name   = "dockerbot93/actions-web-test:latest"
      docker_registry_url = "https://index.docker.io" 
    }
}
output "sample_server_dns" {
  value = aws_instance.sample_server.public_dns
}
