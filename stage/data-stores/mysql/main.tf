terraform {
  backend "s3" {
    bucket  = "ayerst.net-terraform-state"
    key     = "stage/data-stores/mysql/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "mysql" {
  source = "../../../modules/data-stores/mysql"

  instance_name = "mysqlsstage"
  instance_type = "db.t2.micro"
}

output "port" {
  value = "${module.mysql.port}"
}

output "address" {
  value = "${module.mysql.address}"
}
