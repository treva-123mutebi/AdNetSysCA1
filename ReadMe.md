# AdNetSysCA1

This repository demonstrates a full-stack “Infrastructure-as-Code → Configuration Management → Containerization → CI/CD” workflow:

1. **Terraform** to provision an AWS EC2 host  
2. **Ansible** to install Docker and deploy a container  
3. **Docker** to package a static site into an Nginx-based image  
4. **GitHub Actions** to build & publish the image to Docker Hub (and optionally trigger a remote deploy via Ansible)

---

## Prerequisites
- **AWS account** with permissions to create EC2, VPC, etc.  
- **Docker Hub** account for storing images  
- **Local tools**:  
  - [Terraform](https://www.terraform.io/downloads) ≥ 1. → `terraform`  
  - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) ≥ 2.9 → `ansible`, `ansible-galaxy`  
  - [Docker Desktop](https://www.docker.com/products/docker-desktop) → `docker`  
  - [Git](https://git-scm.com/downloads) → `git`  

---

## 1. Clone the Repo

```bash
git clone https://github.com/treva-123mutebi/AdNetSysCA1.git
cd AdNetSysCA1
```
## 2. Configure AWS Credentials
Create a file at `CA1/.aws/credentials` with your AWS access key and secret key:

```bash
 ~/.aws/credentials
[default]
aws_access_key_id     = AKIA…
aws_secret_access_key = …
```
```bash
# ~/.aws/config
[default]
region = eu-north-1
```

Do not commit these files—see .gitignore.

## 3. Provision the EC2 Host (Terraform)
Review and customize variables.tf defaults as needed.
Create a terraform.tfvars in the root (not in Git) with

```bash
subnet_id              = "subnet-09acd045de65cee76"
vpc_security_group_ids = ["sg-033e56ff6410c49c1"]
key_name               = "login"
```
Initialize & apply

```bash

terraform init
terraform apply -var-file=terraform.tfvars
```

## 4. Configure Ansible Inventory
Move your SSH key into ~/.ssh/login.pem and chmod 600 it
Edit config/inventory.ini to point at your host

```ini
[docker_hosts]
docker1 ansible_host=<docker_host_public_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/login.pem
```
Install the Docker collection
```ini
ansible-galaxy collection install community.docker
```

Run the playbook
```bash
ansible-playbook -i config/inventory.ini playbook.yml
```
## 5. Build & Push Docker Image
Build the Docker image
```bash 
docker build -t trevormutebi/ca1:latest .
```
Push to Docker Hub
```bash
docker push trevormutebi/ca1:latest
```
##  6. CI/CD with GitHub Actions
Checkout code

Build & smoke-test the Docker image

Log in to Docker Hub (uses secrets)

Push trevormutebi/ca1:latest

Secrets
In your GitHub repo’s Settings → Secrets → Actions, add:

DOCKERHUB_USERNAME → your Docker Hub user

DOCKERHUB_TOKEN → a Docker Hub access token

(Optional for auto-deploy)

HOST_IP → the EC2 public IP

SSH_PRIVATE_KEY → contents of ~/.ssh/login.pem

If you include the appleboy/ssh-action step, the workflow will SSH into your host and re-run the Ansible playbook automatically.

## 7. Access the Site
Open your browser and navigate to the public IP of your EC2 instance. You should see the static site served by Nginx.

