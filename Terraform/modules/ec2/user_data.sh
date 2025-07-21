#!/bin/bash

# Update system
sudo apt update
sudo apt install -y gnupg2 wget

# Install basic packages
sudo apt-get install -y wget curl git

# Install AWS CLI
sudo apt-get install -y awscli

# Install and configure SSM Agent
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# Install Miniconda3
sudo -u ubuntu mkdir -p /home/ubuntu/miniconda3
sudo -u ubuntu wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/ubuntu/miniconda3/miniconda.sh
sudo -u ubuntu bash /home/ubuntu/miniconda3/miniconda.sh -b -u -p /home/ubuntu/miniconda3
sudo -u ubuntu rm /home/ubuntu/miniconda3/miniconda.sh

echo 'export PATH="/home/ubuntu/miniconda3/bin:$PATH"' | sudo -u ubuntu tee -a /home/ubuntu/.bashrc

# Install PostgreSQL 16
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
sudo apt update
sudo apt install -y postgresql-16 postgresql-contrib-16 postgresql-client-16


sudo systemctl start postgresql
sudo systemctl enable postgresql