provider "aws" {
  region = "eu-west-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "ayerst.net-terraform-state"
  db_remote_state_key    = "prod/data-stores/webserveR_cluster/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 3
  max_size      = 5
}
