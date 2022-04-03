resource "aws_lb" "main" {
  name               = var.cluster_identifier
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = [for s in var.load_balancer_subnet_ids : s]

  tags = {
    Name = var.cluster_identifier
  }
}

resource "aws_lb_listener" "main" {
  for_each = {
    https  = 443
    consul = 8500
    nomad  = 4646
  }

  load_balancer_arn = aws_lb.main.arn
  port              = each.value
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.ingress.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}
