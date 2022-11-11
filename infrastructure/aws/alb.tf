resource "aws_security_group" "app" {
  name        = "allow_app_ports"
  description = "Allow app ports"
  vpc_id      = module.vpc.result.vpc.id

  ingress {
    description      = "HTTP from public"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Backend from public"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "this" {
  name               = "app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app.id]
  subnets            = [for subnet in module.vpc.result.public_subnets : subnet.id]

  enable_deletion_protection = false
}

resource "aws_alb_target_group" "frontend" {
  name        = "frontend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.result.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "frontend" {
  load_balancer_arn = aws_lb.this.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.frontend.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "backend" {
  name        = "backend"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.result.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "backend" {
  load_balancer_arn = aws_lb.this.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.backend.id
    type             = "forward"
  }
}

#resource "aws_alb_listener" "https" {
#  load_balancer_arn = aws_lb.main.id
#  port              = 443
#  protocol          = "HTTPS"

#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = var.alb_tls_cert_arn

#  default_action {
#    target_group_arn = aws_alb_target_group.this.id
#    type             = "forward"
#  }
#}
