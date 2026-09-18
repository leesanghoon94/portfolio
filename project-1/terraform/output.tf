output "public-subnet" {
  value       = aws_subnet.my-public-subnet-a.id
  description = "public subnet-a"

}

output "private-app-subnet" {
  value       = aws_subnet.my-private-subnet-app-a.id
  description = "private subnet-app-a"
}

output "vpc-id" {
  value       = aws_vpc.my-vpc.id
  description = "vpc-id"
}

output "app" {
  value = aws_instance.app.id
}
output "jenkins" {
  value = aws_instance.jenkins.id
}

output "ec2_app_ip" {
  value = aws_instance.app.private_ip
}
