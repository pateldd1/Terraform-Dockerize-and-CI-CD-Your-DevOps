resource "aws_instance" "bastion" {
  ami           = var.bastion_instance_ami # Amazon Linux 2 AMI (HVM)
  instance_type = var.bastion_instance_type

  key_name = var.bastion_key_name

  subnet_id              = tolist(aws_subnet.public.*.id)[0]
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "devops-bastion"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3-pip
              pip3 install ansible
              export DD_API_KEY=$(aws secretsmanager get-secret-value --secret-id datadog_api_key --query SecretString --output text)
              sudo ansible-playbook ./Ansible_Playbook/bastion_host_setup.yml --extra-vars "datadog_api_key=$DD_API_KEY"
              EOF
}

resource "aws_eip" "bastion" {
  vpc      = true
  instance = aws_instance.bastion.id
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}
