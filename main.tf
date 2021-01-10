#Define the EC2 instance
resource "aws_instance" "web_a" {

    count = var.instance_count

    ami           = var.ami
    instance_type = var.instance
  	key_name = aws_key_pair.ovpDevOpsKey.id
    availability_zone = var.az_a
    associate_public_ip_address = true

    #Dynamic subnet assignment
    #subnet_id = sort(data.aws_subnet_ids.dynamic_subnets_list.ids)[count.index]

    subnet_id = aws_subnet.subnet_private_az_a.id

    vpc_security_group_ids = [aws_security_group.internal_access.id, aws_security_group.prometheus_access.id]


    tags = {
        Role = "WebServer"
    }

    #Install Python on remote instance - Ansible needs it!
    provisioner "remote-exec" {
        inline = ["sudo yum -y install python3"]

        #Connection string
        connection {
            host        = self.public_ip
            type        = "ssh"
            user        = var.ansible_user
            private_key = file(var.private_key)
        }
    }

    #Run Ansible playbook on localhost to install Apache on remote instance
    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ${var.private_key} -i ${self.public_ip}, ansible/install-apache.yml"
    }
}
#Define the EC2 instance
resource "aws_instance" "web_b" {

    count = var.instance_count

    ami           = var.ami
    instance_type = var.instance
	  key_name      = aws_key_pair.ovpDevOpsKey.id
    availability_zone = var.az_b
    associate_public_ip_address = true

    vpc_security_group_ids = [aws_security_group.internal_access.id, aws_security_group.prometheus_access.id]

    #Dynamic subnet assignment
    #subnet_id = sort(data.aws_subnet_ids.dynamic_subnets_list.ids)[count.index]

    subnet_id = aws_subnet.subnet_private_az_b.id

    tags = {
        Role = "WebServer"
    }

    #Install Python on remote instance - Ansible needs it!
    provisioner "remote-exec" {
        inline = ["sudo yum -y install python3"]

        #Connection string
        connection {
            host = self.public_ip
            type = "ssh"
            user = var.ansible_user
            private_key = file(var.private_key)
        }
    }

    #Run Ansible playbook on localhost to install Apache on remote instance
    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ${var.private_key} -i ${self.public_ip}, ansible/install-apache.yml"
    }
}

#Stores web servers to attach to ALB - a
data "aws_instances" "web_instances_a" {
  
  instance_state_names = ["running"]
  instance_tags = {
    Role = "WebServer"
  }
  depends_on = [
    aws_instance.web_a
  ]
}

#Stores web servers to attach to ALB - b
data "aws_instances" "web_instances_b" {

  instance_state_names = ["running"]
  instance_tags = {
    Role = "WebServer"
  }
  depends_on = [
    aws_instance.web_b
  ]
}

