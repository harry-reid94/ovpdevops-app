# ovpdevops-app
Home assignment for OVP DevOps team.
## Objectives
1. Design a highly available, production ready AWS web environment
2. Provision the underlying infrastructure with Terraform
3. Deploy a web service on top of the provisioned infra with Ansible
4. Web service must be available via HTTPS and internally redirect to port 8080
5. Points to consider:
   - Monitoring
   - Maintainability
   - Capacity
   - Growth
   - Deploying an environment that already has instances running

### Prerequisites
- Python 2.7
- Ubuntu 18.04
- Ansible 2.5.1
-	Terraform 0.14.4
-	AWS account & AWS CLI
-	Public certificate for custom domain validated by ACM (AWS Certificate Manager). This is required to receive HTTPS requests.

## High Level Design
There are a quite a few moving parts to consider when creating a design a solution of this nature, especially since we are following an Infrastructue as Code approach.
Each element will be constructed as a (or collection of) Terraform modules. The main elements are:
#### VPC
A Virtual Private Cloud that will host our environment. It will also determine what our subnet ranges will be based on the specified CIDR block.

#### Availability Zones
Each AWS region comes with several availability zones. We will deploy EC2 instance(s) containing our web service in each AZ. This provides **geo-resilience** and hence improves the services availability.

#### Subnets
Ideally we will have two subnets per AZ. One subnet will be a public subnet (routes to internet gateway) for 

#### Internet Gateways
#### EC2 Instances

#### Load Balancers
#### Security Groups

## Provisioning

## Deploying

![alt text](https://github.com/harry-reid94/ovpdevops-app/blob/main/images/ovpdevopshld.jpg)



Separation of concerns - directory structure

- [Web Server](https://www.ovpdevops.xyz)
- [Prometheus](http://3.129.24.35:9090)
- [Grafana](http://3.129.24.35:3000)
