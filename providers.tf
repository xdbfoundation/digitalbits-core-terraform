# --- root/providers.tf ---
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

provider "aws" {
  region = "eu-central-1"
  alias  = "eu-central-1"
}

provider "aws" {
  region = "eu-south-1"
  alias  = "eu-south-1"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu-west-1"
}

provider "aws" {
  region = "ap-southeast-1"
  alias  = "ap-southeast-1"
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "ap-southeast-2"
}

provider "aws" {
  region = "ca-central-1"
  alias  = "ca-central-1"
}

provider "aws" {
  region = "sa-east-1"
  alias  = "sa-east-1"
}

provider "aws" {
  region = "eu-north-1"
  alias  = "eu-north-1"
}