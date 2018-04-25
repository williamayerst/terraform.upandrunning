resource "aws_db_instance" "example" {
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "${var.instance_type}"
  name                = "${var.instance_name}db"
  username            = "admin"
  password            = "${var.db_password}"
  skip_final_snapshot = true
}
