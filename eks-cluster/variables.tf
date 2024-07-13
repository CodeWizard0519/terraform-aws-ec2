variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "aimlops-demo"
  type    = string
}

variable "vpc_cidr_block" {
  default = "172.91.0.0/16"
  type    = string
}

variable "disk_size" {
  default = "20"
  type    = string
}

variable "instance_types" {
  default = "t3.large"
  type    = string
}

variable "no_of_public_subnet" {
  default = "2"
}
