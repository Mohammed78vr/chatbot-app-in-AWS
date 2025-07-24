#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y python3 python3-pip awscli jq

# Install SSM agent (usually pre-installed on Ubuntu AMIs)
snap install amazon-ssm-agent --classic
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# Create application directory
mkdir -p /opt/chatbot
cd /opt/chatbot

# Get secrets from AWS Secrets Manager
SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --region ${region} --query SecretString --output text)

# Parse secrets and export as environment variables
export DB_HOST=$(echo $SECRET_VALUE | jq -r '.db_host')
export DB_PORT=$(echo $SECRET_VALUE | jq -r '.db_port')
export DB_NAME=$(echo $SECRET_VALUE | jq -r '.db_name')
export DB_USERNAME=$(echo $SECRET_VALUE | jq -r '.db_username')
export DB_PASSWORD=$(echo $SECRET_VALUE | jq -r '.db_password')
export OPENAI_API_KEY=$(echo $SECRET_VALUE | jq -r '.openai_api_key')
export S3_BUCKET_NAME=$(echo $SECRET_VALUE | jq -r '.s3_bucket_name')
export CHROMADB_HOST=$(echo $SECRET_VALUE | jq -r '.chromadb_host')
export CHROMADB_PORT=$(echo $SECRET_VALUE | jq -r '.chromadb_port')

# Get backend ALB DNS name from parameter
export BACKEND_API_URL="http://${backend_alb_dns_name}:5000"

# Create environment file for the application
cat > /opt/chatbot/.env << EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
OPENAI_API_KEY=$OPENAI_API_KEY
S3_BUCKET_NAME=$S3_BUCKET_NAME
CHROMADB_HOST=$CHROMADB_HOST
CHROMADB_PORT=$CHROMADB_PORT
BACKEND_API_URL=$BACKEND_API_URL
EOF

# Download application files (you'll need to update this with your actual source)
# For now, creating placeholder files
cat > /opt/chatbot/chatbot.py << 'EOF'
import streamlit as st
import os
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

st.title("Chatbot Frontend")
st.write("This is the frontend application running on port 8501")
st.write(f"Connected to database: {os.getenv('DB_HOST')}")
st.write(f"ChromaDB Host: {os.getenv('CHROMADB_HOST')}")
st.write(f"Backend API URL: {os.getenv('BACKEND_API_URL')}")

# Health check endpoint
if st.button("Test Backend Connection"):
    try:
        backend_url = os.getenv('BACKEND_API_URL')
        response = requests.get(f"{backend_url}/health", timeout=5)
        if response.status_code == 200:
            st.success("Backend connection successful!")
            st.json(response.json())
        else:
            st.error(f"Backend returned status code: {response.status_code}")
    except Exception as e:
        st.error(f"Failed to connect to backend: {str(e)}")
EOF

# Install Python dependencies
pip3 install streamlit python-dotenv requests

# Create systemd service for the frontend application
cat > /etc/systemd/system/chatbot-frontend.service << EOF
[Unit]
Description=Chatbot Frontend Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/chatbot
Environment=PATH=/usr/local/bin:/usr/bin:/bin
ExecStart=/usr/local/bin/streamlit run chatbot.py --server.port=8501 --server.address=0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable chatbot-frontend.service
systemctl start chatbot-frontend.service

# Log the completion
echo "Frontend setup completed at $(date)" >> /var/log/user-data.log
