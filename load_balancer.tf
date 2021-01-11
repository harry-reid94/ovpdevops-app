#Create Application LB
resource "aws_alb" "alb" {  
  name                  = "alb"
  subnets               = [aws_subnet.subnet_public_az_a.id, aws_subnet.subnet_public_az_b.id]
  security_groups       = [aws_security_group.web_access.id]
}

#HTTP Listener
resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 8080
  protocol          = "HTTP"
  
  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group_http.arn
    type             = "forward"
  }
}
#HTTPS Listener
resource "aws_alb_listener" "alb_listener_https" {  
  load_balancer_arn = aws_alb.alb.arn  
  port              = 443
  protocol          = "HTTPS"
  #AWS certificate
  certificate_arn   = file(var.cert)
  
  default_action {    
    target_group_arn = aws_alb_target_group.alb_target_group_http.arn
    type             = "forward"  
  }
}

#Forward request to port 8080
resource "aws_alb_listener_rule" "listener_rule_http" {
  listener_arn = aws_alb_listener.alb_listener_https.arn
  
  action {    
    type             = "forward"    
    target_group_arn = aws_alb_target_group.alb_target_group_http.id
  }   
  
  condition {
    host_header {
      values = ["www.ovpdevops.xyz"]
    }
  }
}

#HTTP target group - port 8080
resource "aws_alb_target_group" "alb_target_group_http" {  
  name     = "target-group-http"
  port     = 8080
  protocol = "HTTP"  
  vpc_id   = aws_vpc.vpc.id
  
  stickiness {    
    type            = "lb_cookie"    
  }   
  
  health_check {
    path = "/login"
    port = 8080
  }
}

#Attach Apache instances to HTTP target group
resource "aws_lb_target_group_attachment" "attach_web_a" {

  count = var.instance_count
  target_group_arn = aws_alb_target_group.alb_target_group_http.arn
  #target_id        = aws_instance.web_a.id
  target_id        = data.aws_instances.web_instances_a.ids[count.index]
  port             = 8080
}
resource "aws_lb_target_group_attachment" "attach_web_b" {

  count = var.instance_count
  target_group_arn = aws_alb_target_group.alb_target_group_http.arn
  #target_id        = aws_instance.web_b.id
  target_id        = data.aws_instances.web_instances_b.ids[count.index]
  port             = 8080
}