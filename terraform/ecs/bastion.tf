resource "aws_security_group" "bastion" {
  name        = "example-bastion"
  description = "Allow traffic to the bastion host"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "bastion" {
  ami           = "ami-0533f2ba8a1995cf9" # Amazon Linux 2 AMI (HVM)
  instance_type = "t2.micro"

  key_name = "devpatel-keys"

  subnet_id              = tolist(aws_subnet.public.*.id)[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "example-bastion"
  }
}

resource "aws_eip" "bastion" {
  vpc      = true
  instance = aws_instance.bastion.id
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}
