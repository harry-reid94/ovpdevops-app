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
There are a quite a few moving parts to consider when designing a solution of this nature, especially since we are following an Infrastructue as Code approach.
Each element will be constructed as a (or collection of) Terraform modules. The main to consider elements are:
#### VPC
A Virtual Private Cloud that will host our environment. It will also determine what our subnet ranges will be based on the specified CIDR block.

#### Availability Zones
Each AWS region comes with several availability zones. We will deploy EC2 instance(s) containing our web service in each AZ. This provides **geo-resilience** and hence improves the services availability.

#### Subnets
For this assignment, we will create a public subnet in each AZ. Each subnet will host instances containing web server, along with a monitoring instance. Ideally the web server should be hosted in private subnets, which are routed to the internet via a NAT gateway contained in public subnets, but for this simple server (more on this here) we will stick to public subnets.

#### Internet Gateways
Internet gateway allows communication between the elements within our VPC and the internet. Traffic is routed from IGW to subnets via routing tables which declare routing logic. A route table association then maps this behaviour to the desired subnets.

#### Security Groups
Security groups are our virtual firewall to control inbound and outbound traffic to our instances. For this assignment we will need three security groups:
- Web access: 
#### EC2 Instances
EC2 instances are Linux VMs and are where our web servers will live. Without an auto-scaling group EC2 instances must be statically assigned across AZs, so we will declare two resources - one in each subnet/AZ. For each resource we can have multiple instances. This fact, along with having multiple AZs and the function of our load balancer is how we acheive high availability. 

#### Load Balancers
For this solution, an ALB (Application Load Balancer) is the best pick. A NLB (Network Load Balancer) could not assure availability of our application, and an ELB (Elastic Load Balancer) does not support port forwarding (443 -> 8080) - it is static. <br />
The ALB requires several additional elements to function correctly, the first being a listener. This listens for incoming traffic on a specified port, which gets forwarded to a specified target group based on listener rules. A target group attachment resource attaches any desired instances to a target group. In our case the listener listens on port 443 and forwards over port 8080 to our target group members (web servers instances). <br />
Health checks on each instance are performed to determine which route the traffic is directed. If an instance or AZ is down, the ALB will mark the target as unhealthy and discontinue traffic.

#### Route 53
Route 53 routes requests directed at our custom domain to our ALB. Initially a hosted zone will be created, which can then be updated with records containing mapping logic. <br />
<br />
- A Record: www.ovpdevops.xyz --> ALB hostname <br />
- A Record: ovpdevops.xyz     --> ALB hostname <br />
<br />
Allows users to access the server with or without prefix. <br />

**NOTE: ** For this exercise, our custom domain has been registered outside of AWS, therefore we must get name servers from auto generated NS record on creation of hosted zone and import to custom domain provider for DNS propagation.

## Provisioning

## Deploying

![alt text](https://github.com/harry-reid94/ovpdevops-app/blob/main/images/ovpdevopshld.jpg)

An Auto Scaling group can contain Amazon EC2 instances from multiple Availability Zones within the same Region. However, an Auto Scaling group can't contain instances from multiple Regions.




Separation of concerns - directory structure

- [Web Server](https://www.ovpdevops.xyz)
- [Prometheus](http://3.129.24.35:9090)
- [Grafana](http://3.129.24.35:3000)
