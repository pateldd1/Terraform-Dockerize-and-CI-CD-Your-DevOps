resource "aws_lb" "this" {
  name               = "devops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = aws_subnet.public.*.id
}

resource "aws_lb_target_group" "this" {
  name     = "devops-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = var.alb_target_group_healthcheck_path
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
