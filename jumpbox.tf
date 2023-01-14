# Create security group for jumpbox
resource "aws_security_group" "allow_external" {
  name        = "allow_external"
  description = "Allow  inbound traffic from RDP and SSH"
  vpc_id      = aws_vpc.CloudWave-Project.id

  ingress {
    description      = "RDP"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }  

   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }      
  tags = {
    Name = "jumpbox-sg"
  }
}


# Create an EC2 instance for jumpbox
resource "aws_instance" "jumpbox-ec2" {
  ami           = var.ami_id_for_windows
  instance_type = var.ami_id_for_windows  
  vpc_security_group_ids = [aws_security_group.allow_external.id]
  iam_instance_profile   = local.instance_profile
  subnet_id              = "aws_subnet.cloudwave-private.*.id[count.index]"
  key_name   = var.key_name
  associate_public_ip_address = true
  tags = {
    Name = "CloudWave-jumpbox-ec2"
  }
  
}