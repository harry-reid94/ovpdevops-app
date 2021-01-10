#Output ALB hostname
output "alb_address" {
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
/*
output "Instance_IPs_a" {
  value = data.aws_instances.web_instances_a.public_ips
}

output "Instance_IPs_b" {
  value = data.aws_instances.web_instances_b.public_ips
}
*/
/*
output "Subnets_public" {
  value = data.aws_subnet_ids.dynamic_subnets_list_public
}

output "Subnets_private" {
  value = data.aws_subnet_ids.dynamic_subnets_list_private
}*/