# resource "aws_cloud9_environment_ec2" "example" {
#   instance_type   = "t2.micro"
#   name            = "cloud9"
#   image_id        = "resolve:ssm:/aws/service/cloud9/amis/amazonlinux-2-x86_64"
#   connection_type = "CONNECT_SSM"
#   subnet_id       = aws_subnet.public.id
#   owner_arn       = "arn:aws:iam::992382792232:root"
# }

# data "aws_instance" "cloud9_instance" {
#   filter {
#     name = "tag:aws:cloud9:environment"
#     values = [
#     aws_cloud9_environment_ec2.example.id]
#   }
# }

# output "cloud9_url" {
#   value = "https://${var.region}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.example.id}"
# }

# variable "region" {
#   default = "ap-northeast-2"
# }

# aws iam create-role --role-name AWSCloud9SSMAccessRole --path /service-role/ --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": ["ec2.amazonaws.com","cloud9.amazonaws.com"]},"Action": "sts:AssumeRole"}]}'

# aws iam attach-role-policy --role-name AWSCloud9SSMAccessRole --policy-arn arn:aws:iam::aws:policy/AWSCloud9SSMInstanceProfile

# aws iam create-instance-profile --instance-profile-name AWSCloud9SSMInstanceProfile --path /cloud9/
# aws iam add-role-to-instance-profile --instance-profile-name AWSCloud9SSMInstanceProfile --role-name AWSCloud9SSMAccessRole

#2025월7월이후 신규사용자 이용못함