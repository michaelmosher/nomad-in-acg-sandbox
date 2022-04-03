resource "aws_route53_record" "ingress" {
  zone_id = var.route53_public_zone_id
  name    = var.cluster_identifier
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ingress_validation" {
  allow_overwrite = true
  name            = aws_acm_certificate.ingress.domain_validation_options.*.resource_record_name[0]
  records         = [aws_acm_certificate.ingress.domain_validation_options.*.resource_record_value[0]]
  type            = aws_acm_certificate.ingress.domain_validation_options.*.resource_record_type[0]
  ttl             = 300
  zone_id         = var.route53_public_zone_id
}
