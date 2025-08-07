# Temporary file to check available inventories

data "aap_inventory" "demo_inventory" {
  name              = "Demo Inventory"
  organization_name = "Default"
}

output "demo_inventory_info" {
  value = {
    id   = data.aap_inventory.demo_inventory.id
    name = data.aap_inventory.demo_inventory.name
  }
}