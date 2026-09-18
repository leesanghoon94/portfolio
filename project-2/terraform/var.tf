variable "az_count" {
  default = 2
  type = number
}

variable "vpc_cidr_block" {
  default = "10.1.0.0/16"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "owner-alias"
    values = [ "amazon" ]
  }
  filter {
    name = "name"
    values = [ "amzn2-ami-ecs-hvm-*-x86_64-ebs" ]
  }

  owners = [ "amazon" ]
}