terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-prachi123"
    key            = "phase1/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
