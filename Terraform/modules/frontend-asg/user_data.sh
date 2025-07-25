#!/bin/bash

sudo apt update
sudo apt install -y gnupg2 wget git

sudo -u ubuntu tee /home/ubuntu/chatbot-app-in-AWS/.env <<EOF
SECRET_NAME=${secret_name}
REGION_NAME=${region}
EOF

sudo -u ubuntu systemctl restart frontend