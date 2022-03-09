# Web group - ALB only accesses port 8025
# SMTP group - VPC -> 1025

resource "aws_security_group" "firewall" {
  description = "Rules for ${local.full_name}"
  vpc_id      = var.vpc_id

  # Web port is allowed from anywhere, since the ALB enforces SSO.
  ingress {
    from_port       = 8025
    to_port         = local.web_port
    protocol        = "tcp"
    security_groups = var.alb_security_group_ids
  }

  # SMTP port is only allowed from a Northwestern IP since it is unauthenticated.
  #
  # This is not a real SMTP server so there is no harm in somebody [impotently] sending spam to
  # a web UI that ten people tops look at. But that would be fairly annoying for those ten people.
  ingress {
    from_port   = 1025
    to_port     = 1025
    protocol    = "tcp"
    cidr_blocks = var.smtp_permitted_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.full_name
  }
}