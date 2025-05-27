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

resource "aws_apprunner_service" "web_api" {
    service_name="web_api"
    source_configuration {
      image_repository {
        image_identifier="dockerbot93/actions-web-test:latest"
        image_repository_type = "DOCKER_HUB"
        image_configuration {
            port = "80"
        }
      }
        auto-deployments_enabled = true
    }
}

output "sample_server_dns" {
  value = aws_instance.sample_server.public_dns
}
