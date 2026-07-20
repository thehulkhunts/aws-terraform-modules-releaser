resource "aws_instance" "ec2" {
  for_each = var.ec2_instances
  instance_type = each.value.instance_type
  ami = data.aws_ami.latest.id
  key_name = each.value.key_name
  subnet_id = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = each.value.associate_public_ip_address

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = each.value.volume_type
  }
  tags = {
    Name = "${var.environment}-${each.key}"
    Environment = var.environment
  }
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
//create locals

locals {
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH access from anywhere"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow http access from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow https access from anywhere"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow tcp access from anywhere"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}
// create a security group for ec2_instances
resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id
  name = "${var.environment}-ec2-sg"
  description = "security group for instances"

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  dynamic "egress" {
    for_each = local.egress_rules
    content {
        from_port   = egress.value.from_port
        to_port     = egress.value.to_port
        protocol    = egress.value.protocol
        cidr_blocks = egress.value.cidr_blocks
        description = egress.value.description
    }
  }
  tags = {
  Name        = "${var.environment}-ec2-sg"
  Environment = var.environment
}
}