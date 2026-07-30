variable "vpc_cidr" {
  type = string
  description = "The CIDR block for the VPC"
}
variable "environment" {
  type = string
  description = "The environment for the VPC"
}
variable "public_subnet_cidr" {
  type = list(string)
  description = "The CIDR blocks for the public subnets"
}
variable "availability_zone" {
  type = list(string)
  description = "The availability zones for the subnets"
}
variable "private_subnet_cidr" {
  type = list(string)
  description = "The CIDR blocks for the private subnets"
}