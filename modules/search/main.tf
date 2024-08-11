# -----Create Search Service----- #

resource "azurerm_search_service" "search" {
  name                         = var.search_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku                          = "standard"
  local_authentication_enabled = false
  replica_count                = var.replica_count
  partition_count              = var.partition_count
  hosting_mode                 = var.hosting_mode
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = false

}

resource "azurerm_role_assignment" "search" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_search_service.search.id
  principal_id         = azurerm_search_service.search.identity[0].principal_id
}
