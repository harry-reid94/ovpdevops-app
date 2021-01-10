#Create Application LB
resource "aws_alb" "alb" {  
  name                  = "alb"
  subnets               = [aws_subnet.subnet_az_a.id, aws_subnet.subnet_az_b.id]
  security_groups       = [aws_security_group.web_access.id]
}

#Add LB listeners - HTTP/HTTPS
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 8080
  protocol          = "HTTP"
  
  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}
resource "aws_alb_listener" "alb_listener" {  
  load_balancer_arn = aws_alb.alb.arn  
  port              = 443
  protocol          = "HTTPS"
  #AWS certificate
  certificate_arn   = "arn:aws:acm:us-east-2:999329133891:certificate/391784a9-c098-42e4-9aaa-cf77ec425fd8"
  
  default_action {    
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"  
  }
}

#Forward request to port 8080
resource "aws_alb_listener_rule" "listener_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  
  action {    
    type             = "forward"    
    target_group_arn = aws_alb_target_group.alb_target_group.id
  }   
  
  condition {
    host_header {
      values = ["www.ovpdevops.xyz"]
    }
  }
}
resource "aws_alb_target_group" "alb_target_group" {  
  name     = "target-group"
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

#Attach instances to target group
resource "aws_lb_target_group_attachment" "attach0" {
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = aws_instance.web_a.id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = aws_instance.web_b.id
  port             = 8080
}