resource "aws_acm_certificate" "ingress" {
  domain_name       = aws_route53_record.ingress.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "ingress" {
  certificate_arn         = aws_acm_certificate.ingress.arn
  validation_record_fqdns = [aws_route53_record.ingress_validation.fqdn]
}
