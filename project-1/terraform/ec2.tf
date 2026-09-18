resource "aws_instance" "app" {
  ami             = "ami-0aef7d1237f8a3805"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.my-private-subnet-app-a.id
  security_groups = [aws_security_group.app.id]
  # iam_instance_profile = aws_iam_instance_profile.session_manager.name
  key_name = local.key_pair_name

  tags = {
    Name = "app"
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0aef7d1237f8a3805"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.my-private-subnet-app-a.id
  # iam_instance_profile = aws_iam_instance_profile.session_manager.name
  security_groups = [aws_security_group.jenkins.id]
  key_name        = local.key_pair_name
  user_data       = <<EOF
#!/bin/bash
sleep 30
sudo -i
wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade 
yum install java-21-amazon-corretto jenkins git ansible -y
systemctl enable jenkins
systemctl start jenkins
EOF
  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "openvpn" {
  ami             = "ami-051d52e500c684ec4"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.my-public-subnet-a.id
  security_groups = [aws_security_group.openvpn.id]
  key_name        = local.key_pair_name

  associate_public_ip_address = true


  tags = {
    "Name" = "openvpn"
  }
}

locals {
  key_pair_name = "myKey"
}
