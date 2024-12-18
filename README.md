# bastion-host

The code in the repo is used to create 2 AWS EC2 instances.
Bastion instance is used to access secured instance.
Direct connection to secured instance is prohibited through security group.
The connection between the two is made inside the VPC.
Bastion sshd is configured to allow connections to secured instance only by port 22.
Both instances are configured to allow connections with ssh keys
signed by trusted CA which is created by ansible playbook.
Ansible playbook is also used to generate temporary ssh key
and add ssh hosts configuration to ~/.ssh/config for easily
accessing bastion and secured instances.

### 1. Create EC2 instances with terraform
  ```
  cd terraform
  terraform init
  terraform apply
  ```

### 2. Copy ssh configs, create CA files, create temporary ssh key
  ```
  cd ansible
  ansible-playbook main.yml -i inventory.ini
  ansible-playbook generate_key.yml -i inventory.ini
  ```

### 3. Change security groups port and cidr_block with terraform
  ```
  # Changes to be made are commented im main.tf file
  cd terraform
  terraform apply
  ```

### 4. Accessing instances
  ```
  # Connect to the bastion host using:

  ssh bastion

  # From the bastion host, connect to the private server:

  ssh secured

  # Alternatively, connect directly using your local machine:

  ssh secured
  ```

### Addidional info

  Ansible playbook main.tf changes bastion ssh port to 37271 so it is needed
  to change 22 port in bastion security group to 37271.
  Secured instance cidr_block in security group is also needed to be changed
  to bastion private ip for restricting access from another sources.

  In case of ssh connection error ```Too many authentication failures```
  you need to clear the memory of ssh agent with command:

   ```ssh-add -D```

### Link to the project details: [https://roadmap.sh/projects/bastion-host](https://roadmap.sh/projects/bastion-host).