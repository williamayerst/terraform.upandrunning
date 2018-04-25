terraform {
  backend "s3" {
    bucket  = "ayerst.net-terraform-state"
    key     = "global/s3/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "deleteme" {
  bucket = "ayerst.net-deleteme"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
