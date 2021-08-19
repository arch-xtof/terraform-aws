# terraform-aws
Setup several AWS EC2 instances

## Steps

* Create AWS Access Keys for terraform
* Create AWS Keypair for EC2
* Export Access and Secret key
  ```
  export TF_VAR_aws_access_key=<access_key>
  export TF_VAR_aws_secret_key=<secret_key>
  ```
* Modify **terraform.tfvars** file accordingly
* Initialize Terraform 
  ```
  terraform init
  ```
* Apply the configuration 
  ```
  terraform apply
  ```
