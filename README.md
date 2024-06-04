Local Docker Registry Setup with Ansible

This repository contains Ansible playbooks to set up a local Docker registry with Nginx on a primary server and distribute SSL certificates to all other servers to allow secure image pulling.

Prerequisites
Clone the Repository

sh
Copy code
git clone https://github.com/Avnshrai/local-registry-docker.git
Prepare Certificates

Ensure you have the SSL certificates in the /tmp directory on the primary server with the following names:
nginx-selfsigned.crt
nginx-selfsigned.key
Install Ansible

Follow the official Ansible installation guide: Ansible Installation Guide
Configure Inventory File

Edit the hosts.ini file to add your servers. Example:
ini
Copy code
[server1]
server1 ansible_host=192.168.100.80 ansible_user=core

[all]
server1 ansible_host=192.168.100.80 ansible_user=core
server2 ansible_host=192.168.100.81 ansible_user=core
Running the Playbook
Navigate to the cloned repository directory

sh
Copy code
cd local-registry-docker
Run the Ansible Playbook

sh
Copy code
ansible-playbook -i hosts.ini setup_local_registry.yml
This playbook will set up and run Nginx and Docker Compose on server1, distribute the SSL certificates to the Docker and containerd certificates directories on all other servers, and restart the Docker and containerd services on those servers. This will allow all servers to pull images from the local registry.

Repository Contents
setup_local_registry.yml: The main Ansible playbook for setting up the local Docker registry with Nginx and distributing SSL certificates.
hosts.ini: Sample inventory file to specify the target servers.

