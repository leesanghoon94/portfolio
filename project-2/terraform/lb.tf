resource "aws_lb" "name" {
  name               = "elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets            = aws_subnet.public.*.id
}

resource "aws_lb_target_group" "front" {
  name        = "front-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my-vpc.id
  target_type = "instance"

}


resource "aws_lb_target_group" "back" {
  name        = "back-tg"
  port        = 3333
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my-vpc.id
  target_type = "instance"

  health_check {
    path = "/api/article"
    port = 3333

  }
}

resource "aws_lb_listener" "front" {
  load_balancer_arn = aws_lb.name.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}

resource "aws_lb_listener" "back" {
  load_balancer_arn = aws_lb.name.arn
  port              = 3333
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back.arn
  }


}


# resource "aws_lb_target_group_attachment" "front" {
#   target_group_arn = aws_lb_target_group.front.arn
#   target_id = aws_ecs_service.back
# }

# resource "aws_lb_target_group_attachment" "back" {
#   target_group_arn = aws_lb_target_group.back.arn
#   target_id        = aws_ecs_task_definition.back
#   port             = 3333
# }
