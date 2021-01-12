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
-  Set of public/private SSH keys
-	Public certificate for custom domain validated by ACM (AWS Certificate Manager). This is required to receive HTTPS requests.

### Link to Website
- [www.ovpdevops.xyz](https://www.ovpdevops.xyz/)
- Prometheus & Grafana - availabile on request (IP address subject to change)
<br />

## Proposed Solution

### Architecture 
![alt text](https://github.com/harry-reid94/ovpdevops-app/blob/main/images/ovpdevopshld.jpg)

There are a quite a few moving parts to consider when designing a solution of this nature, especially since we are following an Infrastructue as Code approach.
Each element will be constructed as a (or collection of) Terraform modules. The main elements to consider are:

#### VPC
A Virtual Private Cloud that will host our environment. It will also determine what our subnet ranges will be based on the specified CIDR block.

#### Availability Zones
Each AWS region comes with several availability zones. We will deploy EC2 instance(s) containing our web service in each AZ. This provides **geo-resilience** and hence improves the services availability.

#### Subnets
For this assignment, we will create a public subnet in each AZ. Each subnet will host instances containing web server, along with a monitoring instance. Ideally the web server should be hosted in private subnets, which are routed to the internet via a NAT gateway contained in public subnets, but for this simple server we will stick to public subnets.

#### Internet Gateway
IGW (Internet Gateway) allows communication between the elements within our VPC and the internet. Traffic is routed from IGW to subnets via routing tables which declare routing logic. A route table association then maps this behaviour to the desired subnets.
  
#### Load Balancer
For this solution, an ALB (Application Load Balancer) is the best pick. A NLB (Network Load Balancer) could not assure availability of our application, and an ELB (Elastic Load Balancer) does not support port forwarding. <br />
The ALB requires several additional elements to function correctly, the first being a listener. This listens for incoming traffic on a specified port, which gets forwarded to a specified target group based on listener rules. A target group attachment resource attaches desired instances to a target group. In our case the listener listens on port 443 and forwards over port 8080 to our target group members which are our web servers instances. <br />
Health checks on each instance are performed to determine which route the traffic is directed. If an instance or AZ is down, the ALB will mark the target as unhealthy and discontinue traffic.

#### EC2 Instances
We will have two types of EC2 instance resources:
- Web servers: These instances will contain our Apache web server. Initially we will create an empty instance and utilize the provisioner function in Terraform to populate the instance with the required resources. Provisioner can run commands on the local and remote host (instance) during resource creation. First we need to install Python on the instance in order to run Ansible. Then on the local host we will run an Ansible playbook which creates and configures Apache to listen on port 8080 on the instance. Our web server is now good to go. We will be able to specify how many of each instance (per AZ) to be created. Declaring a data module containing a list of all created instances allows us to map them to our load balancer by iterating through each one in the target group attachment phase. <br />
Without an auto-scaling group EC2 instances must be statically assigned across AZs, so we will declare two resources - one in each subnet/AZ. For each resource we can have multiple instances. This fact, along with having multiple AZs and the function of our load balancer is how we acheive **high availability**. 
- Monitoring: Alongside our web server instance(s), we will have a instance responsible for monitoring the web server instances. For this solution, we will run Prometheus and Grafana in Docker. First we will create a Prometheus config file that points our Prometheus instance to all instances in our desired region and scrapes metrics from port 9100. By once again utilizing the provisioner function, we can transfer this prometheus config file to the instance and then run our other Ansible playbook which does the following:
  - Installs Docker
  - Inputs IAM details into Prometheus config file
  - Starts Prometheus Docker container, bind mounts config file to container and maps port 9090 (Prometheus GUI)
  - Starts Grafana Docker container and maps port 3000 (Grafana GUI).

#### Security Groups
Security groups are our virtual firewall to control inbound and outbound traffic to our instances. For this assignment we will need four security groups:
- HTTP access - for web instances: 
  - Ingress: 8080
  - Egress: All
- HTTPS access - for load balancer:
  - Ingress: 443
  - Egress: All
- Internal access - for all instances:
  - Ingress: 22
  - Egress: All
- Prometheus access - for all instances:
  - Ingress: 3000, 9090, 9100
  - Egress: All
  
#### Route 53
Route 53 routes requests directed at our custom domain to our ALB. Initially a hosted zone will be created, which can then be updated with records containing mapping logic. <br />
- A Record: www.ovpdevops.xyz --> ALB hostname <br />
- A Record: ovpdevops.xyz     --> ALB hostname <br />

**NOTE:** For this exercise, our domain has been registered outside of AWS, therefore upon creation of the hosted zone we must get the four name servers from the auto generated  NS record and import these to the custom domain provider for DNS propagation.

## How to Run
You must first be logged into you AWS account on CLI and have the following items configured in the specified directories on your local machine:
```
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
```
The variable `hosted_zone` in `variables.tf` should also be configured to your own custom domain.<br />

From the base repo directory run the following:
```
terraform init
terraform plan
terraform apply
```
From the output, take your four name servers and upload them to your domain provider and wait for several hours for propagation. The Apache web server should then be available at `https://<domain>.<extension>` or `https://www.domain>.<extension>`. 

## Considerations
1. **Monitoring:** Included in solution
2. **Maintainability:** Avoiding code repitition greatly increases maintainability. Even in this small assignment there is quite a lot of repetitive code - mainly from creating resources in different availability zones. Would be interesting to find out how to iterate over availability zones for one module. Another strategy to consider is abstracting common modules out into another directory. In a real-life situation, there would be a staging directory containing all staging infrastructure and a production directory containing all production infrastructure. By abstracting out the modules shared by both environments, code repitition is reduced. 
3. **Capacity/Growth:** In the current solution, up to 20 web server instances can be created by modifying the count variable, all of which will be dynamically attached to the ALB. This creation however is not predictive. That is where auto-scaling comes in. Auto-scaling takes care of any capacity issues whilst also reducing costs. Minimum and maximum instance numbers can be specified, along with desired states. Instances are created/destroyed based on incoming traffic. This deals with potential spikes in traffic. ECS is a highly scalable service that should be also considered.
4. **Deploying to an existing environment:** Pull the current environment from Git and build on top of it. Or build the new environment in a different region if the two environments are to be kept separate.

## Areas of Improvement
- The web servers should be hosted in private subnets. The servers then communicate with the internet via NAT gateways in public subnets. This is considered best practice and improves security. My attempt to create this architecture failed as I could not SSH via provisioner into the instances (in private subnets) to run Ansible playbooks etc.
- All provisioner steps in Prometheus instance creation (file transfer, remote-exec and local-exec) can be performed using one Ansible playbook (I think). Would improve maintainability.
- Running Docker within an EC2 instance is probably not considered best practice. Maybe better to run prometheus on ECS?
- Database should be attached to web server instances somehow. What is best practice here? And how do DBs in different AZs communicate/share data?
- Auto-scaling.
- Refactor Prometheus Ansible script to utilize ansible modules more rather than just running shell commands.
- Another possible solution would be to create ECS cluster, and deploy the web server into containers within the ECS cluster.

## Appendix
### Rough Design Ideas
![alt text](https://github.com/harry-reid94/ovpdevops-app/blob/main/images/ovpdesignidea.jpg)
<br />
![alt text](https://github.com/harry-reid94/ovpdevops-app/blob/main/images/ovpfirstdesignidea.jpg)
