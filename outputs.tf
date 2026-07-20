output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "instance_ids" {
  value = {
    for k, v in aws_instance.ec2 :
    k => v.id
  }
}

//private ip's
output "private_ips" {
  value = {
    for k, v in aws_instance.ec2 :
    k => v.private_ip
  }
}