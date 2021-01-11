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
variable cert {
  description   = "SSL Certificate"
  default       = "~/ovp_devops_app/ovp_devops_app/certificates/aws_acm.txt"
}


#CIDR & subnets
variable cidr_vpc {
  description   = "CIDR for our VPC"
  default       = "10.0.0.0/16"
}
variable "cidr_subnet_public_a" {
    description = "CIDR block for the public facing subnet."
    default     = "10.0.128.0/20"
}
variable "cidr_subnet_public_b" {
    description = "CIDR block for the public facing subnet."
    default     = "10.0.144.0/20"
}
variable "cidr_subnet_private_a" {
    description = "CIDR block for the private facing subnet."
    default     = "10.0.0.0/19"
}
variable "cidr_subnet_private_b" {
    description = "CIDR block for the private facing subnet."
    default     = "10.0.32.0/19"
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
