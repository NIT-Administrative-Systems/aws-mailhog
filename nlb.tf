resource "aws_lb" "smtp" {
  name               = local.full_name_slug
  internal           = true
  load_balancer_type = "network"
  subnets            = var.nlb_subnet_ids
}

resource "aws_lb_listener" "smtp" {
  load_balancer_arn = aws_lb.smtp.arn
  port              = local.smtp_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.smtp.arn
  }

}

# So TF knows when to re-generate the target group name
resource "random_id" "nlb_target" {
  keepers = {
    vpc_id = var.vpc_id
  }

  byte_length = 4
}


resource "aws_lb_target_group" "smtp" {
  name        = "${local.full_name_slug}-${random_id.nlb_target.hex}-smtp"
  port        = local.smtp_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}