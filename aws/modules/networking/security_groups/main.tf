resource "aws_security_group" "main" {
    for_each = var.security_groups
    name = each.key
    description = each.value.description
    vpc_id = var.vpc_id
    
    tags = merge(
        var.tags,
        {
            Name = each.key
        }
    )
}
//create ingress security group rule
resource "aws_security_group_rule" "ingress" {
  for_each = {
    for rule in flatten([
       for sg_name, sg in var.security_groups : [
          for index, ingress in sg.ingress_rules : {
            key = "${sg_name}-${index}"
            security_group = sg_name
            rule = ingress
          }
       ]
    ]) : rule.key => rule
  }
  type = "ingress"
  security_group_id = aws_security_group.main[each.value.security_group].id
  from_port = each.value.rule.from_port
  to_port = each.value.rule.to_port
  protocol = each.value.rule.protocol
  cidr_blocks = each.value.rule.cidr_blocks
  description = each.value.rule.description
}

//create egress security group
resource "aws_security_group_rule" "egress" {
  for_each = {
    for rule in flatten([
      for sg_name, sg in var.security_groups : [
        for index, egress in sg.egress_rules : {
          key = "${sg_name}-${index}"
          security_group = sg_name
          rule = egress
        }
      ]
    ]) : rule.key => rule

  }
  type = "egress"
  security_group_id = aws_security_group.main[each.value.security_group].id
  from_port = each.value.rule.from_port
  to_port   = each.value.rule.to_port
  protocol = each.value.rule.protocol
  description = each.value.rule.description
  cidr_blocks = each.value.rule.cidr_blocks

}