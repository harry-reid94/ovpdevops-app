#AWS region
variable region {
  description   = "AWS region"
  default       = "us-east-2"
}


#EC2 instance variables
variable instance_count {
  description   = "Number of EC2 instances"
  default       = 1
}
variable ami {
  description   = "AMI version"
  default       = "ami-0a0ad6b70e61be944"
}
variable instance {
  description   = "Type of EC2 instance"
  default       = "t2.micro"
}

#Ansible user
variable ansible_user {
  description   = "Ansible user"
  default       = "ec2-user"
}
#Ubuntu user
variable ubuntu_user {
  description   = "Ubuntu user"
  default       = "ubuntu"
}

#Keychain
variable public_key {
  description   = "Public SSH key"
  default       = "~/.ssh/MyKeyPair.pub"
}
variable private_key {
  description   = "Private SSH key"
  default       = "~/.ssh/MyKeyPair.pem"
}


#Certificates
variable cert {
  description   = "SSL Certificate"
  default       = "~/ovp_devops_app/ovp_devops_app/certificates/aws_acm.txt"
}


#CIDR & subnets
variable cidr_vpc {
  description   = "CIDR for our VPC"
  default       = "172.16.0.0/16"
}
variable "cidr_subnet_a" {
    description = "CIDR block for the public facing subnet."
    default     = "172.16.64.0/24"
}
variable "cidr_subnet_b" {
    description = "CIDR block for the public facing subnet."
    default     = "172.16.128.0/24"
}
variable "cidr_subnet_prom_a" {
    description = "CIDR block for the public facing subnet."
    default     = "172.16.16.0/24"
}
variable "cidr_subnet_prom_b" {
    description = "CIDR block for the public facing subnet."
    default     = "172.16.32.0/24"
}


#Availability zones
variable az_a {
  description   = "Availablilty Zone for the subnet"
  default       = "us-east-2a"
}
variable az_b {
  description   = "Availablilty Zone for the subnet"
  default       = "us-east-2b"
}

#Hosted zone
variable hosted_zone {
  default       = "ovpdevops.xyz"  
}
