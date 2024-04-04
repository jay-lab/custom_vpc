terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2" # Asia Pacific (Seoul) region
}

#resource "aws_key_pair" "mykey" {
#  key_name   = "mykey"
#  public_key = file("mykey.pub")
#}