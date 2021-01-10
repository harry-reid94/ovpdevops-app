
# prometheus instance
resource "aws_instance" "prometheus_a" {
  ami               = "ami-0dd9f0e7df0f0a138"
  instance_type     = var.instance
  key_name               = aws_key_pair.ovpDevOpsKey.id
  subnet_id              = aws_subnet.subnet_prom_az_a.id

  vpc_security_group_ids = [aws_security_group.prometheus_access.id]

  #Install Python on remote instance - Ansible needs it!


 provisioner "file" {
    source      = "./prometheus/prometheus_config.yml"
    destination = "/tmp/prometheus.yml"

    connection {
            host        = self.public_ip
            type        = "ssh"
            user        = "ubuntu"
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
            user        = "ubuntu"
            private_key = file(var.private_key)
        }
    }

  #Run Ansible playbook on localhost to install Apache on remote instance
  provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${var.private_key} -i ${self.public_ip}, ansible/install-prometheus.yml"
    }

 provisioner "remote-exec" {
        inline = [
            "sudo mkdir /prometheus-data",
            "sudo cp /tmp/prometheus.yml /prometheus-data/.",
            "sudo sed -i 's;<access_key>;${aws_iam_access_key.prometheus_access_key.id};g' /prometheus-data/prometheus.yml",
            "sudo sed -i 's;<secret_key>;${aws_iam_access_key.prometheus_access_key.secret};g' /prometheus-data/prometheus.yml",
            "sudo docker run -d -p 9090:9090 --name=prometheus -v /prometheus-data/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus",
            "sudo docker run -d -p 3000:3000 --name=grafana grafana/grafana"
            ]
        #Connection string
        connection {
            host        = self.public_ip
            type        = "ssh"
            user        = "ubuntu"
            private_key = file(var.private_key)
        }
    }  

/*
# Copy the prometheus file to instance
  provisioner "file" {
    source      = "./prometheus/prometheus_config.yml"
    destination = "/tmp/prometheus.yml"
  }
# Install docker in the ubuntu
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt update",
      "sudo apt -y install docker-ce",
      "sudo mkdir /prometheus-data",
      "sudo cp /tmp/prometheus.yml /prometheus-data/.",
      "sudo sed -i 's;<access_key>;${aws_iam_access_key.prometheus_access_key.id};g' /prometheus-data/prometheus.yml",
      "sudo sed -i 's;<secret_key>;${aws_iam_access_key.prometheus_access_key.secret};g' /prometheus-data/prometheus.yml",
      "sudo docker run -d -p 9090:9090 --name=prometheus -v /prometheus-data/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus",
      "sudo docker run -d -p 3000:3000 --name=grafana grafana/grafana"

    ]
  }
  provisioner "local-exec" {
    command = "chmod 400 ${aws_key_pair.ovpDevOpsKey.id}.pem"
    #command = "echo '${var.private_key}' >> ${aws_key_pair.ovpDevOpsKey.id}.pem ; chmod 400 ${aws_key_pair.ovpDevOpsKey.id}.pem"
  }
  */
}