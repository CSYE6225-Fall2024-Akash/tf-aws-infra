# Fetch the hosted zone
data "aws_route53_zone" "domain" {
  name         = "${var.environment}.${var.domain_name}"
  private_zone = false
}

# Create A record for the ALB
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.webapp.dns_name
    zone_id                = aws_lb.webapp.zone_id
    evaluate_target_health = true
  }
}