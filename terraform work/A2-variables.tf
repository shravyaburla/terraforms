# variables.tf

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "alb_name" {
  default = "my-alb"
}

variable "ami_id" {
  default = "ami-0ddfba243cbee3768"  # Replace with the correct AMI ID in your region
}
