#Create public hosted zone
resource "aws_route53_zone" "zone" {
  name = var.hosted_zone
}

#Create two A records and map to DNS hostname
resource "aws_route53_record" "A" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.hosted_zone
  type    = "A"

  alias {
    name                   = "dualstack.${aws_alb.alb.dns_name}"
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "A_www" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "www.${var.hosted_zone}"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_alb.alb.dns_name}"
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}