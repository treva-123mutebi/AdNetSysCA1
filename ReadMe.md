# Quickstart Guide for AdNetSysCA1

Follow these steps in order. Using Terraform, Docker, Guthub and Github Actions, this guide will help you deploy a static site on an AWS EC2 instance using Docker.

---

## 1. Clone the repository

```bash
git clone https://github.com/treva-123mutebi/AdNetSysCA1.git
cd AdNetSysCA1
```

---

## 2. Configure AWS credentials

In **your home directory**, create or update:

```ini
# ~/.aws/credentials
[default]
aws_access_key_id     = <YOUR_AWS_ACCESS_KEY_ID>
aws_secret_access_key = <YOUR_AWS_SECRET_ACCESS_KEY>
```

```ini
# ~/.aws/config
[default]
region = eu-north-1
output = json
```

> **Do not** commit these files.

---

## 3. Supply Terraform variables

At the repo root, create `terraform.tfvars`:

```hcl
subnet_id              = "<YOUR_SUBNET_ID>"
vpc_security_group_ids = ["<YOUR_SECURITY_GROUP_ID>"]
key_name               = "<YOUR_KEYPAIR_NAME>"
```

---

## 4. Provision the EC2 host (Terraform)

```bash
terraform init
terraform apply -var-file=terraform.tfvars -auto-approve
```

> **Output**: Note the `docker_host_public_ip`.

---

## 5. Configure Ansible

1. **Move** your SSH key and set permissions:

   ```bash
   mv <PATH_TO_YOUR_LOGIN.PEM> ~/.ssh/login.pem
   chmod 600 ~/.ssh/login.pem
   ```

2. **Edit** `config/inventory.ini`, replacing `<IP>`:

   ```ini
   [docker_hosts]
   docker1 ansible_host=<docker_host_public_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/login.pem
   ```

3. **Install** the Docker Ansible collection:

   ```bash
   ansible-galaxy collection install community.docker
   ```

---

## 6. Run the Ansible playbook

```bash
ansible-playbook -i config/inventory.ini playbook.yml
```

* Installs Docker on the EC2 host
* Adds `ubuntu` to the `docker` group
* Clones/updates the Git repo on the host
* Starts the `webapp` container (binding port 80)

---

## 7. Push a change to trigger CI/CD

Make an empty commit to fire GitHub Actions:

```bash
git commit --allow-empty -m "Trigger CI/CD"
git push origin main
```

**GitHub Actions** will then:

1. Build & smoke-test the Docker image
2. Push `trevormutebi/ca1:latest` to Docker Hub
3. SSH into your EC2 and run:

   ```bash
   docker pull trevormutebi/ca1:latest
   docker rm -f webapp || true
   docker run -d --name webapp \
     --restart=always -p 80:80 \
     trevormutebi/ca1:latest
   ```

---

## 8. Verify the deployment

Open in your browser:

```
http://<docker_host_public_ip>
```

You should see your static site served by Nginx.

---

## 9. Tear down

When finished, destroy all resources:

```bash
terraform destroy -var-file=terraform.tfvars -auto-approve
```
