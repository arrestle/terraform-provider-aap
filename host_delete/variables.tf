# Variables for host deletion configuration

variable "inventory_id" {
  description = "ID of the inventory containing the host"
  type        = number
}

variable "host_name" {
  description = "Name of the host to delete"
  type        = string
}

variable "host_description" {
  description = "Description of the host (if any)"
  type        = string
  default     = ""
}

variable "host_enabled" {
  description = "Whether the host is enabled"
  type        = bool
  default     = true
}

variable "host_variables" {
  description = "Host variables as JSON or YAML string"
  type        = string
  default     = ""
}

variable "host_groups" {
  description = "List of group IDs the host belongs to"
  type        = list(number)
  default     = []
}

variable "delete_timeout" {
  description = "Timeout in seconds for delete operations"
  type        = number
  default     = 120
}