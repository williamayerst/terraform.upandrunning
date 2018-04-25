// Back-End Information about the Database to be streamed into the Website

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "eu-west-2"
  }
}

// Sourcing data from AWS for the availability Zone deployments
data "aws_availability_zones" "all" {}

// Version 1 of the Template file to be added to the Web Server Deployments
data "template_file" "user_data" {
  // count = "${1 - var.enable_new_user_data}"  When enable_new_user_data is false it is 0, therefore this is 1, and is created

  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
    server_text = "${var.server_text}"
  }
}

/* Version 2 of the Template file to be added to the Web Server Deployments
data "template_file" "user_data_new" {
  count = "${var.enable_new_user_data}" // When enable_new_user_data is true it is 1, therefore this is 1, and is created

  template = "${file("${path.module}/user-data-new.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
  }
} */

resource "aws_launch_configuration" "example" {
  key_name        = "terraform"
  image_id        = "${var.ami}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}", "${var.security_group_default}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "example" {
  name               = "${var.cluster_name}-elb"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  lifecycle {
    create_before_destroy = true
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.elb.id}"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.elb.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-sg"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "upandrunning"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name                 = "${var.cluster_name}-${aws_launch_configuration.example.name}"
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  min_elb_capacity     = "${var.min_size}"
  load_balancers       = ["${aws_elb.example.name}"]
  health_check_type    = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = "${var.enable_autoscaling}"

  scheduled_action_name  = "scale-out-during-business-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.example.name}"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = "${var.enable_autoscaling}"

  scheduled_action_name  = "scale-in-at-night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.example.name}"
}
