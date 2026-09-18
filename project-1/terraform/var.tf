variable "vpc_id" {
  type = string
  default = "vpc-0907f68a98d2d9425"
}

variable "public-subnet" {
  type = list(string)
  default = [ "subnet-075c2db77df1ea8d1" ]
}

variable "private-subnet" {
  type = list(string)
  default = [ "subnet-080d2a0023f06cbea" ]
}