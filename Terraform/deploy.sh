#!/bin/bash

# Terraform deployment script
set -e

echo "🚀 Starting Terraform deployment..."

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found!"
    echo "Please copy terraform.tfvars.example to terraform.tfvars and update with your values."
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Format code
echo "🎨 Formatting Terraform code..."
terraform fmt -recursive

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
read -p "Do you want to apply this plan? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔨 Applying Terraform configuration..."
    terraform apply tfplan
    
    echo "✅ Deployment completed successfully!"
    echo ""
    echo "📊 Outputs:"
    terraform output
    
    # Clean up plan file
    rm -f tfplan
else
    echo "❌ Deployment cancelled."
    rm -f tfplan
    exit 1
fi
