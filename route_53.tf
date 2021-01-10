#Create public hosted zone
resource "aws_route53_zone" "zone" {
  name = var.hosted_zone
}

#Create A records and map to ALB - for web instances
#Maps access from "ovpdevops.xyz"
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
#Maps access from "www.ovpdevops.xyz"
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
/*
#Create A records and map to Prometheus instances
#Maps access from "ovpdevops.xyz" - Instance A
resource "aws_route53_record" "prom_A_a" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.hosted_zone
  type    = "A"

  alias {
    name                   = aws_instance.prometheus_a.public_ip
    zone_id                = aws_route53_zone.zone.zone_id
    evaluate_target_health = true
  }

  latency_routing_policy {
    region = var.region
  }
  set_identifier = "latency"
}
#Maps access from "ovpdevops.xyz" - Instance B
resource "aws_route53_record" "prom_A_b" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.hosted_zone
  type    = "A"

  alias {
    name                   = aws_instance.prometheus_b.public_ip
    zone_id                = aws_route53_zone.zone.zone_id
    evaluate_target_health = true
  }

  latency_routing_policy {
    region = var.region
  }
  set_identifier = "latency"

}
#Maps access from "www.ovpdevops.xyz" - Instance A
resource "aws_route53_record" "prom_A_www_a" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.hosted_zone
  type    = "A"

  alias {
    name                   = aws_instance.prometheus_a.public_ip
    zone_id                = aws_route53_zone.zone.zone_id
    evaluate_target_health = true
  }

  latency_routing_policy {
    region = var.region
  }
  set_identifier = "latency"
}
#Maps access from "www.ovpdevops.xyz" - Instance B
resource "aws_route53_record" "prom_A_www_b" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.hosted_zone
  type    = "A"

  alias {
    name                   = aws_instance.prometheus_b.public_ip
    zone_id                = aws_route53_zone.zone.zone_id
    evaluate_target_health = true
  }

  latency_routing_policy {
    region = var.region
  }
  set_identifier = "latency"
}
*/
