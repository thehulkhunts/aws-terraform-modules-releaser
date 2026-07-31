output "security_group_ids" {
  value = {
    for name, sg in aws_security_group.main :
    name => sg.id
  }
}