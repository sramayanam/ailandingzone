variable "resource_group_id" {}
variable "location" {}
variable "machine_learning_workspace_name" {}
variable "appi_id" {}
variable "acr_id" {}
variable "storage_account_id" {}
variable "key_vault_id" {}
variable "search_id" {}
variable "openai_id" {}
variable "user_principal_ids" {}
variable "search_name" {}
variable "openai_name" {}
variable "search_admin_key" {}
variable "openai_key" {}
variable "tenantid" {}
variable "compute_subnet_id" {}


variable "virtual_network_name" {}
variable "virtual_network_resource_group_name" {}
variable "private_endpoints_subnet_name" {}
variable "private_dns_zone_resource_group_name" {}
variable "private_endpoints" {
  type = object({
    privateEndpointName    = string
    resourceId             = string
    privateEndpointGroupId = string
    privateDnsZoneName     = list(string)
    resourceGroupName      = string
    azureResourceName      = string
  })
}
