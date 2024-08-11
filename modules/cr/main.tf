# Purpose: Create Azure Container Registry

resource "azurerm_container_registry" "this" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "this" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = var.storage_account_id
  principal_id         = azurerm_container_registry.this.identity[0].principal_id
}
