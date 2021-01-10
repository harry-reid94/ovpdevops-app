#Define the EC2 instance
resource "aws_instance" "web_a" {
    ami           = var.ami
    instance_type = var.instance
	key_name = aws_key_pair.ovpDevOpsKey.id
    subnet_id = aws_subnet.subnet_az_a.id

    vpc_security_group_ids = [aws_security_group.internal_access.id,aws_security_group.web_access.id]

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
    ami           = var.ami
    instance_type = var.instance
	key_name      = aws_key_pair.ovpDevOpsKey.id

    vpc_security_group_ids = [aws_security_group.internal_access.id,aws_security_group.web_access.id]

    subnet_id = aws_subnet.subnet_az_b.id

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
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ${var.private_key} -i ${self.public_ip}, ansible/install-nginx.yml"
    }
}
