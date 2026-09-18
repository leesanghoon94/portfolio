resource "aws_security_group" "ecs_alb_sg" {
  name = "ecs_alb_sg"
  vpc_id = aws_vpc.my-vpc.id
  
  # ingress {
  #   from_port = 80
  #   to_port = 80
  #   protocol = "tcp"
  #   cidr_blocks = [ "0.0.0.0/0" ]
  # }

  # ingress {
  #   from_port = 443
  #   to_port = 443
  #   protocol = "tcp"
  #   cidr_blocks = [ "0.0.0.0/0" ]
  # }
  # ingress {
  #   from_port = 3333
  #   to_port = 3333
  #   protocol = "tcp"
  #   cidr_blocks = [ "0.0.0.0/0" ]
  # }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = "-1"
  }
}

resource "aws_security_group" "ecs_sg" {
  name = "ecs_sg"
  vpc_id = aws_vpc.my-vpc.id

  # ingress {
  #   from_port = 0
  #   to_port = 65535 
  #   protocol = "tcp"
  #   security_groups = [ aws_security_group.ecs_alb_sg.id ]
  # }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = "-1"
  }
}