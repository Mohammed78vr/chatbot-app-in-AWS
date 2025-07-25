#!/bin/bash

sudo apt update
sudo apt install -y gnupg2 wget git

sudo -u ubuntu tee /home/ubuntu/chatbot-app-in-AWS/.env <<EOF
SECRET_NAME=my-chatbot-secrets-262
REGION_NAME=us-east-1
EOF

sudo -u ubuntu systemctl restart backend