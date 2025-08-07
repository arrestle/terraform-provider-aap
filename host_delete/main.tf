terraform {
  required_providers {
    aap = {
      source = "ansible/aap"
    }
  }
}

# Provider configuration - credentials will be read from environment variables
# Make sure to source the local .env file: source .env
provider "aap" {
  # These values will be automatically read from environment variables:
  # host     = from AAP_HOST (https://52.91.46.167/)
  # username = from AAP_USERNAME (admin)  
  # password = from AAP_PASSWORD (Admin!Password!Ctrl)
  # insecure_skip_verify = from AAP_INSECURE_SKIP_VERIFY (true)
}

# Example: Import and delete an existing host
# First, you need to import the existing host using:
# terraform import aap_host.target_host <host_id>

resource "aap_host" "target_host" {
  inventory_id = var.inventory_id
  name         = var.host_name
  description  = var.host_description
  enabled      = var.host_enabled
  
  # Optional: Add variables if the host has them
  variables = var.host_variables
  
  # Optional: Add groups if the host belongs to any groups  
  # Only set groups if the list is not empty (due to validation requirement)
  groups = length(var.host_groups) > 0 ? var.host_groups : null
  
  # Optional: Configure timeout for delete operations
  wait_for_completion_timeout_seconds = var.delete_timeout
}

# To delete this host:
# 1. Comment out or remove the resource above
# 2. Run: terraform apply
# OR
# 3. Run: terraform destroy -target=aap_host.target_host