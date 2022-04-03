data "aws_route53_zone" "public" {
  name         = local.cloud_lab_dns
  private_zone = false
}

data "aws_availability_zones" "available" {
  state = "available"
}
