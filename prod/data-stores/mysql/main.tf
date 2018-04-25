provider "aws" {
  region = "eu-west-2"
}

module "mysql" {
  source = "../../../modules/services/mysql"

  instance_name          = "mysql-prod"
  db_remote_state_bucket = "ayerst.net-terraform-state"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"
}
