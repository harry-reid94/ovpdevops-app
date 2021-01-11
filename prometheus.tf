
#prometheus instance
resource "aws_instance" "prometheus_a" {
  ami               = "ami-0dd9f0e7df0f0a138"
  instance_type     = var.instance
  key_name               = aws_key_pair.ovpDevOpsKey.id
  subnet_id              = aws_subnet.subnet_public_az_a.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.prometheus_access.id]

  #Install Python on remote instance - Ansible needs it!


 provisioner "file" {
    source      = "./prometheus/prometheus_config.yml"
    destination = "/tmp/prometheus.yml"

    connection {
            host        = self.public_ip
            type        = "ssh"
            user        = var.ubuntu_user
            private_key = file(var.private_key)
        }
  }
  
  provisioner "remote-exec" {
        inline = [
            "sudo apt -y install python",
            "export ACCESS_KEY_ID=${aws_iam_access_key.prometheus_access_key.id}",
            "export ACCESS_KEY_SECRET=${aws_iam_access_key.prometheus_access_key.secret}"
            ]
        #Connection string
        connection {
            host        = self.public_ip
            type        = "ssh"
            user        = var.ubuntu_user
            private_key = file(var.private_key)
        }
    }

  #Run Ansible playbook on localhost to install Apache on remote instance
  provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${var.private_key} --extra-vars 'prometheus_access_key=${aws_iam_access_key.prometheus_access_key.id} prometheus_access_secret=${aws_iam_access_key.prometheus_access_key.secret}' -i ${self.public_ip}, ansible/install-prometheus.yml"
    }
}

# prometheus instance
resource "aws_instance" "prometheus_b" {
  ami               = "ami-0dd9f0e7df0f0a138"
  instance_type     = var.instance
  key_name               = aws_key_pair.ovpDevOpsKey.id
  subnet_id              = aws_subnet.subnet_public_az_b.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.prometheus_access.id]

  #Install Python on remote instance - Ansible needs it!


 provisioner "file" {
    source      = "./prometheus/prometheus_config.yml"
    destination = "/tmp/prometheus.yml"

    connection {
            host        = self.public_ip
            type        = "ssh"
            user        = var.ubuntu_user
            private_key = file(var.private_key)
        }
  }
  
  provisioner "remote-exec" {
        inline = [
            "sudo apt -y install python",
            "export ACCESS_KEY_ID=${aws_iam_access_key.prometheus_access_key.id}",
            "export ACCESS_KEY_SECRET=${aws_iam_access_key.prometheus_access_key.secret}"
            ]
        #Connection string
        connection {
            host        = self.public_ip
            type        = "ssh"
            user        = var.ubuntu_user
            private_key = file(var.private_key)
        }
    }

  #Run Ansible playbook on localhost to install Apache on remote instance
  provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${var.private_key} --extra-vars 'prometheus_access_key=${aws_iam_access_key.prometheus_access_key.id} prometheus_access_secret=${aws_iam_access_key.prometheus_access_key.secret}' -i ${self.public_ip}, ansible/install-prometheus.yml"
    } 
}
