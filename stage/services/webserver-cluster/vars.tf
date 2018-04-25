variable "aws_region" {
  description = "The AWS region to use"
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  default     = "webservers-stage"
}

variable "db_remote_state_bucket" {
  description = "The S3 bucket used for the database's remote state"
  default     = "ayerst.net-terraform-state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  default     = "stage/data-stores/mysql/terraform.tfstate"
}
