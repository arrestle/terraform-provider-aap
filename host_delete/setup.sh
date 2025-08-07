#!/bin/bash

# Setup script for host deletion configuration

echo "Setting up AAP Host Delete Configuration..."

# Check if local .env file exists
if [ -f ".env" ]; then
    echo "✅ Found existing .env file in host_delete directory with credentials"
    echo "   - AAP_HOST: $(grep AAP_HOST .env | head -1 | cut -d'=' -f2)"
    echo "   - AAP_USERNAME: $(grep AAP_USERNAME .env | cut -d'=' -f2)"
    echo "   - AAP_INSECURE_SKIP_VERIFY: $(grep AAP_INSECURE_SKIP_VERIFY .env | cut -d'=' -f2)"
else
    echo "❌ No .env file found in host_delete directory"
    echo "   Please create a .env file with your AAP credentials."
fi

# Create terraform.tfvars from example if it doesn't exist
if [ ! -f "terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "✅ Created terraform.tfvars file. Please edit it with your host details."
else
    echo "ℹ️  terraform.tfvars file already exists."
fi

echo ""
echo "📋 Next steps:"
echo "1. Edit terraform.tfvars with your host details"
echo "2. Source the environment: source .env"
echo "3. Initialize terraform: terraform init"
echo "4. Import existing host: terraform import aap_host.target_host <host_id>"
echo "5. Apply configuration: terraform apply"
echo ""
echo "For detailed instructions, see README.md"