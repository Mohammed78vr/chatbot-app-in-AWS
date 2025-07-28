#!/bin/bash

sudo apt update
sudo apt install -y gnupg2 wget git postgresql-client

sudo -u ubuntu tee /home/ubuntu/chatbot-app-in-AWS/.env <<EOF
SECRET_NAME=${secret_name}
REGION_NAME=${region}
EOF

# Database names
DEFAULT_DB="postgres"
TARGET_DB="${db_name}"
DB_HOST="${db_host}"
DB_USERNAME="${db_username}"
DB_PASSWORD="${db_password}"

# Set up PostgreSQL database
echo "Setting up database..."

# Step 1: Create the 'TARGET_DB' database
echo "Creating the $TARGET_DB database..."
psql "host=$DB_HOST port=5432 dbname=$DEFAULT_DB user=$DB_USERNAME password=$DB_PASSWORD sslmode=require" \
    -c "CREATE DATABASE $TARGET_DB;" 2>/dev/null || echo "Database '$TARGET_DB' already exists."

# Step 2: Create the 'advanced_chats' table in the 'TARGET_DB' database
echo "Creating the 'advanced_chats' table in the $TARGET_DB database..."
psql "host=$DB_HOST port=5432 dbname=$TARGET_DB user=$DB_USERNAME password=$DB_PASSWORD sslmode=require" \
    -c "CREATE TABLE IF NOT EXISTS advanced_chats (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        pdf_path TEXT,
        pdf_name TEXT,
        pdf_uuid TEXT
    );"

echo "Database setup completed successfully."

sudo -u ubuntu systemctl restart backend