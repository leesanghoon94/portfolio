resource "aws_db_instance" "mydb" {
  identifier               = "mysql"
  allocated_storage        = 10
  db_name                  = "article"
  engine                   = "mysql"
  engine_version           = "8.0"
  instance_class           = "db.t3.micro"
  username                 = "root"
  password                 = "12345678"
  parameter_group_name     = "rds-pg"
  skip_final_snapshot      = true
  db_subnet_group_name     = aws_db_subnet_group.defualt.name
  vpc_security_group_ids   = [aws_security_group.ecs_sg.id]
  delete_automated_backups = true
}

resource "aws_db_subnet_group" "defualt" {
  name       = "main"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    "Name" = "my DB subnet group"
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "mysql8.0"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
