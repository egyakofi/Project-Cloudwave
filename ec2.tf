

locals {
  instance_profile = aws_iam_instance_profile.cloudwave-profile.name
}

data "aws_ami" "ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
    
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "appserver-sg" {
  name        = "appserver-sg"
  description = "Allow jumpbox inbound traffic on port 80"
  vpc_id      = local.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    #cidr_blocks      = ["10.0.0.0/16"]
    security_groups =  ["${aws_security_group.allow_external.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "appserver-sg"
  }
}


resource "aws_security_group_rule" "appserver-ingress-http-inboudrule" {

  security_group_id        = aws_security_group.appserver-sg.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb-sg.id # alb id 
}


resource "aws_instance" "appserver-instance" {
  count                  = length(local.azs)
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.appserver-sg.id]
  iam_instance_profile   = local.instance_profile
  #subnet_id              = aws_subnet.cloudwave-private.*.id[count.index]

  tags = {
    Name = "app-instance"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted  = true

  }
}

resource "aws_lb_target_group_attachment" "nat-attach" {
count = length(aws_instance.appserver-instance)
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.appserver-instance[count.index].id
  port             = 80
}


#DB Security Group
resource "aws_security_group" "dbserver-sg" {
  name        = "dbserver-sg"
  description = "Allow alb inbound traffic from appserver and jumpbox"
  vpc_id      = local.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    #cidr_blocks      = ["10.0.0.0/16"]
    security_groups =  ["${aws_security_group.appserver-sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "appserver-sg"
  }
}

#DB Server in private Subnet
resource "aws_instance" "dbserver-instance" {
  count                  = length(local.azs)
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.dbserver-sg.id]
  iam_instance_profile   = local.instance_profile
  subnet_id              = aws_subnet.cloudwave-private.*.id[count.index]

  tags = {
    Name = "dbserver-instance"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted  = true

  }
}
