variable "ec2_instances" {
  type = map(object({
    instance_type = string
    key_name = string
    subnet_id = string
    volume_size = number
    volume_type = string
    associate_public_ip_address = bool
    security_group_ids = list(string)
  }))
}

variable "environment" {
  type = string
  description = "environment for instances"
}
