resource "aws_lb" "webapp" {
  name               = "${var.environment}-webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id] # Need at least 2 subnets

  enable_deletion_protection = false

  tags = {
    Name        = "${var.environment}-webapp-alb"
    Environment = var.environment
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "webapp" {
  name     = "${var.environment}-webapp-tg"
  port     = 3000 # Your application port
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/healthz" 
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.environment}-webapp-tg"
    Environment = var.environment
  }
}

# Listener for HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.webapp.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp.arn
  }
}
