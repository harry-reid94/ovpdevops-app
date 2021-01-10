#Output ALB hostname
output "address" {
    value = aws_alb.alb.dns_name
}

#Output Name Servers - add to domain hosting service for propagation!!
output "name_servers" {  
  value = aws_route53_zone.zone.name_servers
}

  
output "Grafana_URL" {
  value = "http://${aws_instance.prometheus_a.public_ip}:3000"
}

output "Prometheus_URL" {
  value = "http://${aws_instance.prometheus_a.public_ip}:9090"
}