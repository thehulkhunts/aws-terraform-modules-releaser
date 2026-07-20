variable "ec2_instances" {
  type = map(object({
    instance_type = string
    key_name = string
    subnet_id = string
    volume_size = number
    volume_type = string
    associate_public_ip_address = bool
  }))
}

variable "environment" {
  type = string
  description = "environment for instances"
}

variable "vpc_id" {
  type = string
  description = "vpc_id"
}