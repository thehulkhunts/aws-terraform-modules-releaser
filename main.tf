resource "aws_instance" "ec2" {
  for_each = var.ec2_instances
  instance_type = each.value.instance_type
  ami = data.aws_ami.latest.id
  key_name = each.value.key_name
  subnet_id = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = each.value.volume_type
  }
  tags = merge(
    var.tags, 
    {
    Name = "${var.environment}-${each.key}"
  }
)
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ami" "latest" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "image-id"
    values = [data.aws_ssm_parameter.ami.value]
  }
}

#removed security groups here, as it is belongs to vpc