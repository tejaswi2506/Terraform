terraform {
  backend "s3" {
    bucket         = "tf-state-993399330785-prod-lab"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-prod-lab"
    encrypt        = true
  }
}