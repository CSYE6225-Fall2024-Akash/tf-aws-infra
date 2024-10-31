# Fetch the hosted zone
data "aws_route53_zone" "domain" {
  name         = "${var.environment}.${var.domain_name}"
  private_zone = false
}

# Create A record
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = data.aws_route53_zone.domain.name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web_app.public_ip]
}