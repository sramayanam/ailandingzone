data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# This initializes the subnet data source
data "azurerm_subnet" "this" {
  provider             = azurerm.platform
  name                 = var.private_endpoints_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group_name
}

resource "random_id" "random" {
  byte_length = 8
}

# ----------------- Initialize the local variables -----------------  #
locals {
  sufix                = var.use_random_suffix ? substr(lower(random_id.random.hex), 1, 4) : ""
  name_sufix           = var.use_random_suffix ? "${local.sufix}" : ""
  resource_group_name  = "${var.resource_group_name}${local.name_sufix}"
  storage_account_name = "${var.storage_account_name}${local.name_sufix}"
  keyvault_name        = "${var.keyvault_name}${local.name_sufix}"
  log_name             = "${var.log_name}${local.name_sufix}"
  appi_name            = "${var.appi_name}${local.name_sufix}"
  acr_name             = "${var.acr_name}${local.name_sufix}"
  search_name          = "${var.search_name}${local.name_sufix}"
  mlw_name             = "${var.mlw_hub_name}${local.name_sufix}"
  private_endpoints = [
    {
      privateEndpointName    = "pe-${local.name_sufix}-${module.st.name}-blob"
      resourceId             = module.st.id
      privateEndpointGroupId = "blob"
      privateDnsZoneName     = "privatelink.blob.core.windows.net"
      resourceGroupName      = var.virtual_network_resource_group_name
      azureResourceName      = module.st.name
    },
    {
      privateEndpointName    = "pe-${local.name_sufix}-file"
      resourceId             = module.st.id
      privateEndpointGroupId = "file"
      privateDnsZoneName     = "privatelink.file.core.windows.net"
      resourceGroupName      = var.virtual_network_resource_group_name
      azureResourceName      = module.st.name
    },
    {
      privateEndpointName    = "pe-${local.name_sufix}-${module.kv.name}"
      resourceId             = module.kv.id
      privateEndpointGroupId = "vault"
      privateDnsZoneName     = "privatelink.vaultcore.azure.net"
      resourceGroupName      = var.virtual_network_resource_group_name
      azureResourceName      = module.kv.name
    },
    {
      privateEndpointName    = "pe-${local.name_sufix}-${module.cr.name}"
      resourceId             = module.cr.id
      privateEndpointGroupId = "registry"
      privateDnsZoneName     = "privatelink.azurecr.io"
      resourceGroupName      = var.virtual_network_resource_group_name
      azureResourceName      = module.cr.name
    },
    {
      privateEndpointName    = "pe-${local.name_sufix}-${module.search.name}"
      resourceId             = module.search.id
      privateEndpointGroupId = "searchService"
      privateDnsZoneName     = "privatelink.search.windows.net"
      resourceGroupName      = var.virtual_network_resource_group_name
      azureResourceName      = module.search.name
    }
  ]
  private_endpoints_ai = {
    privateEndpointName    = "pe-${local.name_sufix}-${module.ai.name}-aistudio"
    resourceId             = module.ai.id
    privateEndpointGroupId = "amlworkspace"
    privateDnsZoneName     = ["privatelink.api.azureml.ms", "privatelink.notebooks.azure.net"]
    resourceGroupName      = var.virtual_network_resource_group_name
    azureResourceName      = module.st.name
  }

}

# ----------------- Initialize the modules --------------------  #
# ------------This module creates a storage account ------------ #
module "st" {
  source               = "./modules/st"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  storage_account_name = local.storage_account_name
  container_names      = {}
}

# ------------This module creates a key vault ------------ #
module "kv" {
  source              = "./modules/kv"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  keyvault_name       = local.keyvault_name
  tags                = var.tags
}

# --- This module creates a log Analytics Workspace ------- #
module "logs" {
  source              = "./modules/observability/logs"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  log_name            = var.log_name
  tags                = var.tags
}

# --- This module creates an Application Insights instance --- #
module "appi" {
  source              = "./modules/observability/appi"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  appi_name           = local.appi_name
  log_id              = module.logs.log_id
  tags                = var.tags
}

# --------- This module creates a container registry ---------- #
module "cr" {
  source              = "./modules/cr"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  acr_name            = local.acr_name
  storage_account_id  = module.st.id
}

# ---------- This module creates a search service -------------- #
module "search" {
  source              = "./modules/search"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  search_name         = local.search_name
  search_sku          = var.search_sku
  semantic_search_sku = var.semantic_search_sku
  replica_count       = var.search_replica_count
  partition_count     = var.search_partition_count
  hosting_mode        = var.hosting_mode

}

# ---------- This module creates a machine learning workspace -------------- #
module "ai" {
  providers = {
    azurerm.platform  = azurerm.platform
    azurerm.analytics = azurerm.analytics
  }
  source                               = "./modules/ai"
  resource_group_id                    = data.azurerm_resource_group.rg.id
  location                             = var.location
  machine_learning_workspace_name      = local.mlw_name
  appi_id                              = module.appi.id
  acr_id                               = module.cr.id
  storage_account_id                   = module.st.id
  key_vault_id                         = module.kv.id
  search_id                            = module.search.id
  openai_id                            = module.openai.id
  user_principal_ids                   = var.user_principal_ids
  search_name                          = local.search_name
  openai_name                          = var.openai_name
  search_admin_key                     = module.search.key
  openai_key                           = module.openai.key
  tenantid                             = var.tenantid
  compute_subnet_id                    = data.azurerm_subnet.this.id
  private_endpoints                    = local.private_endpoints_ai
  virtual_network_name                 = var.virtual_network_name
  private_dns_zone_resource_group_name = var.private_dns_zone_resource_group_name
  virtual_network_resource_group_name  = var.virtual_network_resource_group_name
  private_endpoints_subnet_name        = var.private_endpoints_subnet_name

}

# ---------- This module creates a private endpoint -------------- #
# ---------- PE for blob storage, file              -------------- #
# ---------- PE for key vault, container registry  --------------- #
# ---------- PE for search service                 --------------- #
# ---------- PE for AI workspace                    -------------- #
module "pe" {
  providers = {
    azurerm.platform  = azurerm.platform
    azurerm.analytics = azurerm.analytics
  }
  count                                = var.enable_private_endpoints ? 1 : 0
  source                               = "./modules/pe"
  virtual_network_name                 = var.virtual_network_name
  private_dns_zone_resource_group_name = var.private_dns_zone_resource_group_name
  virtual_network_resource_group_name  = var.virtual_network_resource_group_name
  private_endpoints_subnet_name        = var.private_endpoints_subnet_name
  private_endpoints                    = local.private_endpoints
}

# ---------- This module creates an openai service -------------- #
module "openai" {
  providers = {
    azurerm.platform  = azurerm.platform
    azurerm.analytics = azurerm.analytics
  }
  source                               = "./modules/aiservices"
  resource_group_name                  = data.azurerm_resource_group.rg.name
  location                             = var.location
  cognitive_name                       = "${var.openai_name}-${local.name_sufix}"
  tags                                 = var.tags
  cognitive_private_endpoint_name      = "pe-${local.name_sufix}-${var.openai_private_endpoint_name}"
  deployments                          = var.openai_deployments
  virtual_network_name                 = var.virtual_network_name
  virtual_network_resource_group_name  = var.virtual_network_resource_group_name
  private_endpoints_subnet_name        = var.private_endpoints_subnet_name
  private_dns_zone_resource_group_name = var.private_dns_zone_resource_group_name
}

# ---------- This module creates a role-based access control ------------------ #
# ---------- Create oai contrb, user access for given users  ------------------ #
module "rbac" {
  source                    = "./modules/aisvcrbac"
  contributor_principal_ids = var.contributor_principal_ids
  user_principal_ids        = var.user_principal_ids
  cognitive_service_id      = module.openai.id
}

# ---------- This module creates a diagnostic setting ------------------ #
module "diagnostics" {
  source                     = "./modules/diagnostics"
  openai_account_id          = module.openai.id
  diagnostic_setting         = var.diagnostic_setting
  storage_account_id         = module.st.id
  log_analytics_workspace_id = module.logs.log_id
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.rg.name
}
