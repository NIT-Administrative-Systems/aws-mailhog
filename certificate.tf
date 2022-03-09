resource "aws_acm_certificate" "for_webserver" {
  domain_name       = var.hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}