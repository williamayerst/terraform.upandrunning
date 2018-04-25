terraform {
  backend "s3" {
    bucket  = "ayerst.net-terraform-state"
    key     = "stage/services/webserver-cluster/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = "${var.cluster_name}"
  db_remote_state_bucket = "${var.db_remote_state_bucket}"
  db_remote_state_key    = "${var.db_remote_state_key}"
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 2
  enable_autoscaling     = true
  ami                    = "ami-403e2524"
  server_text            = "Ayerst.NET"
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = "${module.webserver_cluster.elb_security_group_id}"

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
