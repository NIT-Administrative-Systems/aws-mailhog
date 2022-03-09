resource "aws_alb_listener" "listener" {
  load_balancer_arn = var.alb_arn
  port              = local.web_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.for_webserver.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "The mailhog is out hunting for truffles."
      status_code  = "502"
    }
  }
}

# So TF knows when to re-generate the target group name
resource "random_id" "target_group_id" {
  keepers = {
    vpc_id = var.vpc_id
  }

  byte_length = 4
}

# Group of targets (EC2s, Lambdas, Containers, etc) traffic is sent to based on rules
resource "aws_alb_target_group" "webserver" {
  name                 = "${local.full_name_slug}-${random_id.target_group_id.hex}"
  port                 = local.web_port
  protocol             = "HTTP"
  deregistration_delay = 90
  vpc_id               = var.vpc_id
  target_type          = "ip"

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 60
    path                = "/"
    matcher             = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener_rule" "to_ecs" {
  listener_arn = aws_alb_listener.listener.arn

  action {
    type = "authenticate-oidc"

    authenticate_oidc {
      client_id              = var.oicd_client_id
      client_secret          = var.oicd_secret
      authorization_endpoint = "https://login.microsoftonline.com/7d76d361-8277-4708-a477-64e8366cd1bc/oauth2/v2.0/authorize"
      issuer                 = "https://login.microsoftonline.com/7d76d361-8277-4708-a477-64e8366cd1bc/v2.0"
      token_endpoint         = "https://login.microsoftonline.com/7d76d361-8277-4708-a477-64e8366cd1bc/oauth2/v2.0/token"
      user_info_endpoint     = "https://graph.microsoft.com/oidc/userinfo"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }

  condition {
    host_header {
      values = [var.hostname]
    }
  }
}