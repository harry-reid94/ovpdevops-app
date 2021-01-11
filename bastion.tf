/*## Create Bastion Server
resource "aws_security_group" "sg_22" {

  name   = "sg_22"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-22"
  }

}

# Create NACL for access bastion host via port 22
resource "aws_network_acl" "ovpdevops_public" {
  vpc_id = aws_vpc.vpc.id

  subnet_ids = [aws_subnet.subnet_public_az_a.id, aws_subnet.subnet_public_az_b.id] 
}

resource "aws_network_acl_rule" "inbound_rule_22" {
  network_acl_id = aws_network_acl.ovpdevops_public.id
  rule_number    = 200
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}
resource "aws_network_acl_rule" "outbound_rule_22" {
  network_acl_id = aws_network_acl.ovpdevops_public.id
  rule_number    = 200
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}
# Create NACL for access bastion host via port 22

resource "aws_instance" "ovpdevops_bastion_a" {
  ami                    = var.ami
  instance_type          = var.instance
  subnet_id              = aws_subnet.subnet_public_az_a.id
  vpc_security_group_ids = [aws_security_group.sg_22.id]
  key_name               = aws_key_pair.ovpDevOpsKey.key_name

  #Install Python on remote instance - Ansible needs it!
    provisioner "remote-exec" {
        inline = ["sudo yum -y install python3"]

        #Connection string
        connection {
            host = aws_nat_gateway.ngw_a.public_ip
            type = "ssh"
            user = var.ansible_user
            private_key = file(var.private_key)
        }
    }
  
}


*/