# Terraform.UpandRunning

This is the companion repo for the O'Reilly book of the same name, it will deploy an auto-scaling group of web servers (as a custom module), and a mysql server (again, as a module) to either staging or production. It makes use of conditional (if/then) functions, loops and substitutions within TF itself. The primary purpose of this exercise was to cover all major resource types (data, terraform, backend) and include them in a single deployment.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

```text
Terraform
AWS Account with an IAM user that has deployment roles for EC2, RDS
```

### Installing

Git Clone the repository to a local file system

```bash
git clone <repo name>
```

Navigate to the global area and set up your S3 state backend. This is used to ensure that a remote and central source of truth is used for your deployments. You will need to edit the file to reflect your settings:

```bash
cd ./global/s3
vim main.tf
terraform init
terraform plan
terraform apply
```

Turning on "versioning" on this bucket is optional but recommended.

Navigate to your chosen environment and plan/apply the Database back end.

```bash
cd ./stage/data-stores/mysql
terraform init
terraform get
terraform plan
terraform apply
```

Navigate to your chosen environment and plan/apply the Web Server front end.

```bash
cd ./stage/services/webserver-cluster
terraform init
terraform get
terraform plan
terraform apply
```

## Running the tests

These tests can be performed locally by the CI/CD process or the end user.

### Back-end Testing

After you deploy the s3 backend (initial step) you should be able to review the bucket contents and see the .tfstate files being generated for other deployments. As the webserver-cluster depends on output from the mysql database deployment (in the form of output variables in the tfstate file) to configure a connection, it's a good idea to check that:

```bash
wget ayerstnet-testbucket.s3-eu-west-2.amazonaws.com/terraform/stage/data-stores/mysql/tf.tfstate | grep output
```

### Front-end Testing

You will recieve an output of an ELB CNAME upon deployment of the webserver-cluster, you can use this to verify the system is working correctly.

```bash
curl ayerstnet-elb.amazonaws.com
```

## Deployment

The `prod` environment is significantly behind `stage` in configuration maturity and may be incompatible. Validate this manually ahead of time (pull requests gladly accepted)

## Built With

* [Terraform](http://www.hashicorp.com) - The cloud deployment framework used
* VSCode

## Contributing

Pull requests gladly accepted, although I'm not expecting this repository to be particularly popular!

## Versioning

This repo represents an entire deployment infrastructure, as such individual semantic versioning seems in appropriate. A better solution would be to split the modules into separate git repos and version those.

## Authors

* **William Ayerst** - *Initial work* - [AyerstNet](https://ayerst.net)

## License

N/A

## Acknowledgments

* O'Reilly's "Terraform: Up and Running"
