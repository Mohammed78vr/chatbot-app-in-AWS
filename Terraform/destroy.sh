#!/bin/bash

# Terraform destroy script
set -e

echo "🗑️  Starting Terraform destroy..."

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found!"
    echo "Please ensure terraform.tfvars exists before destroying resources."
    exit 1
fi

# Show what will be destroyed
echo "📋 Planning destruction..."
terraform plan -destroy

# Ask for confirmation
echo ""
echo "⚠️  WARNING: This will destroy ALL resources created by this Terraform configuration!"
read -p "Are you sure you want to destroy all resources? Type 'yes' to confirm: " -r
echo

if [[ $REPLY == "yes" ]]; then
    echo "🔨 Destroying Terraform resources..."
    terraform destroy -auto-approve
    
    echo "✅ All resources have been destroyed successfully!"
else
    echo "❌ Destruction cancelled."
    exit 1
fi
