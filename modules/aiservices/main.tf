# Module: aiservices

## Description
# This module provisions Azure Cognitive Services resources, including a cognitive account and private endpoints.

## Requirements
# - Terraform version 0.13 or higher
# - Azure provider version 2.0 or higher

## Providers
# - `azurerm.analytics`: Required provider for provisioning the cognitive account and cognitive deployment resources.
# - `azurerm.platform`: Required provider for retrieving virtual network, subnet, and private DNS zone resources.

## Inputs
# - `cognitive_name`: The name of the cognitive account. (string)
# - `cognitive_kind`: The kind of cognitive account. (string)
# - `cognitive_sku`: The SKU name of the cognitive account. (string)
# - `location`: The location where the resources will be provisioned. (string)
# - `resource_group_name`: The name of the resource group where the resources will be created. (string)
# - `virtual_network_name`: The name of the virtual network where the private endpoints will be created. (string)
# - `virtual_network_resource_group_name`: The name of the resource group where the virtual network is located. (string)
# - `private_endpoints_subnet_name`: The name of the subnet where the private endpoints will be created. (string)
# - `private_dns_zone_name`: The name of the private DNS zone. (string)
# - `private_dns_zone_resource_group_name`: The name of the resource group where the private DNS zone is located. (string)
# - `tags`: Tags to be assigned to the private endpoint resources. (map)

## Outputs
# - `cognitive_account_id`: The ID of the cognitive account.
# - `private_endpoint_ids`: The IDs of the private endpoints.

## Usage

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.80"
      configuration_aliases = [azurerm.platform, azurerm.analytics]
    }
  }
}

resource "azurerm_cognitive_account" "this" {
  provider                      = azurerm.analytics
  name                          = var.cognitive_name
  kind                          = var.cognitive_kind
  sku_name                      = var.cognitive_sku
  location                      = var.location
  resource_group_name           = var.resource_group_name
  public_network_access_enabled = false
  custom_subdomain_name         = lower(var.cognitive_name)
  dynamic_throttling_enabled    = false
  identity {
    type = "SystemAssigned"
  }
}

# data resource to get the vnet
data "azurerm_virtual_network" "this" {
  provider            = azurerm.platform
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}


data "azurerm_subnet" "this" {
  provider             = azurerm.platform
  name                 = var.private_endpoints_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group_name
}


data "azurerm_private_dns_zone" "this" {
  provider            = azurerm.platform
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

resource "azurerm_private_endpoint" "endpoint" {
  provider            = azurerm.platform
  name                = var.cognitive_private_endpoint_name
  location            = data.azurerm_virtual_network.this.location
  resource_group_name = var.virtual_network_resource_group_name
  subnet_id           = data.azurerm_subnet.this.id
  tags                = var.tags

  private_service_connection {
    name                           = var.cognitive_private_endpoint_name
    private_connection_resource_id = azurerm_cognitive_account.this.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "dnsgroup"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.this.id]
  }
}

resource "azurerm_cognitive_deployment" "deployment" {
  provider             = azurerm.analytics
  for_each             = { for idx, deployment in var.deployments : idx => deployment }
  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.this.id
  rai_policy_name      = each.value.model.rai_policy_name
  model {
    format  = each.value.model.format
    name    = each.value.model.name
    version = each.value.model.version
  }
  scale {
    type     = each.value.sku.name
    capacity = each.value.sku.capacity
  }

  depends_on = [
    azurerm_cognitive_account.this,
    azurerm_private_endpoint.endpoint
  ]
}

resource "azurerm_role_assignment" "oai" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_cognitive_account.this.id
  principal_id         = azurerm_cognitive_account.this.identity[0].principal_id
}

#### Modifying cognitive services to latest ai services ###############
resource "azurerm_ai_services" "cognitive_service" {
  name                = "appliedaisvcs-${var.cognitive_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "S0"


  tags = {
    Acceptance = "Test"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "appai" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_ai_services.cognitive_service.id
  principal_id         = azurerm_ai_services.cognitive_service.identity[0].principal_id
}

