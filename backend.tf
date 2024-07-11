terraform {
  backend "s3" {
    bucket = "my-terraform-junaid"
    key    = "ecs/terraform.tfstate"
    region = "ap-south-1"
  }
}