# Host Delete Configuration

This directory contains Terraform configuration for deleting AAP hosts.

## Setup

1. **Source credentials**: Use the credentials from the local .env file:
   ```bash
   source .env
   ```

3. **Configure host details**: Copy the example variables file and update:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your host details
   ```

## Usage

### Method 1: Import existing host and then delete

1. **Import the existing host**:
   ```bash
   terraform import aap_host.target_host <host_id>
   ```

2. **Plan the import**:
   ```bash
   terraform plan
   ```

3. **Apply to sync state**:
   ```bash
   terraform apply
   ```

4. **Delete the host** by commenting out the resource in `main.tf` and running:
   ```bash
   terraform apply
   ```

### Method 2: Direct destruction

If you have already imported the host:
```bash
terraform destroy -target=aap_host.target_host
```

### Method 3: Complete cleanup

To destroy all resources:
```bash
terraform destroy
```

## Environment Variables

The provider uses these environment variables:

- `AAP_HOST` - AAP server URL (required)
- `AAP_USERNAME` - AAP username (required)
- `AAP_PASSWORD` - AAP password (required)
- `AAP_INSECURE_SKIP_VERIFY` - Skip SSL verification (optional, default: false)
- `AAP_TIMEOUT` - HTTP timeout in seconds (optional, default: 60)

## Notes

- Make sure you have the correct permissions to delete hosts in AAP
- The delete operation may take time depending on the host configuration
- Use the `wait_for_completion_timeout_seconds` parameter to adjust timeout