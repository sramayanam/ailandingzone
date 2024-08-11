
terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.80"
      configuration_aliases = [azurerm.platform, azurerm.analytics]
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

# --- This module creates an ai studio resource --- #

resource "azapi_resource" "this" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-01-01-preview"
  name      = var.machine_learning_workspace_name
  parent_id = var.resource_group_id
  location  = var.location
  identity {
    type = "SystemAssigned"
  }
  body = {
    kind = "Hub",
    sku = {
      name = "Basic",
      tier = "Basic"
    },
    properties = {
      "keyVault" : var.key_vault_id,
      "containerRegistry" : var.acr_id,
      "applicationInsights" : var.appi_id,
      "managedNetwork" : {
        "isolationMode" : "AllowInternetOutbound",
        "outboundRules" : {
          "bloboutbound" : {
            "category" : "UserDefined",
            "destination" : {
              "serviceResourceId" : var.storage_account_id,
              "sparkEnabled" : true,
              "sparkStatus" : "active",
              "subresourceTarget" : "blob"
            },
            "type" : "PrivateEndpoint"
          },
          "fileoutbound" : {
            "category" : "UserDefined",
            "destination" : {
              "serviceResourceId" : var.storage_account_id,
              "sparkEnabled" : true,
              "sparkStatus" : "active",
              "subresourceTarget" : "file"
            },
            "type" : "PrivateEndpoint"
          },
          "searchoutbound" : {
            "category" : "UserDefined",
            "destination" : {
              "serviceResourceId" : var.search_id,
              "sparkEnabled" : true,
              "sparkStatus" : "active",
              "subresourceTarget" : "searchService"
            },
            "type" : "PrivateEndpoint"
          },
          "openaioutbound" : {
            "category" : "UserDefined",
            "destination" : {
              "serviceResourceId" : var.openai_id,
              "sparkEnabled" : true,
              "sparkStatus" : "active",
              "subresourceTarget" : "account"
            },
            "type" : "PrivateEndpoint"
          },
          "kvoutbound" : {
            "category" : "UserDefined",
            "destination" : {
              "serviceResourceId" : var.key_vault_id,
              "sparkEnabled" : true,
              "sparkStatus" : "active",
              "subresourceTarget" : "vault"
            },
            "type" : "PrivateEndpoint"
          }
        }
      },
      "publicNetworkAccess" : "Disabled",
      "serverlessComputeSettings" : null,
      "storageAccount" : var.storage_account_id,
      "systemDatastoresAuthMode" : null,
      "v1LegacyMode" : false,
      "workspaceHubConfig" : {
        "defaultWorkspaceResourceGroup" : var.resource_group_id
      }
    },
    tags = {
    }
  }
}

# --- This module creates an ai project resource --- #
resource "azapi_resource" "aiproject" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-01-01-preview"
  name      = "aiproject123"
  parent_id = var.resource_group_id
  location  = var.location
  identity {
    type = "SystemAssigned"
  }
  body = {
    kind = "Project",
    sku = {
      name = "Basic",
      tier = "Basic"
    },
    properties = {
      "friendlyName" : "aiprojdefault1",
      "v1LegacyMode" : false,
      "publicNetworkAccess" : "Disabled",
      "ipAllowlist" : [],
      "enableSoftwareBillOfMaterials" : false,
      "hubResourceId" : azapi_resource.this.id,
      "enableDataIsolation" : true
    },
    tags = {
      "ailandingzone" = "true"
    }
  }
}

# --- -This module creates a compute instance resource --------------------------------------------- #
# --- This resource is disabled because of issues in the current version of the azapi provider ------#

/*
resource "azurerm_machine_learning_compute_instance" "this" {
  name                          = "ci${var.machine_learning_workspace_name}${count.index}"
  machine_learning_workspace_id = azapi_resource.this.id
  virtual_machine_size          = "Standard_DS3_v2"
  authorization_type            = "personal"
  location                      = var.location
  count                         = length(var.user_principal_ids)
  node_public_ip_enabled        = true
  assign_to_user {
    object_id = var.user_principal_ids[count.index]
    tenant_id = var.tenantid
  }
  description = "default compute instance"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "ailandingzone" = "true"
  }
}
*/

# --- This module creates a openai connection resource --------------------------------------------- #
# --- This resource is disabled because of issues in the current version of the azapi provider ------#
/*
resource "azapi_resource" "oaiconn" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview"
  name      = "azoaisecconn"
  parent_id = azapi_resource.this.id
  body = {
    "properties" : {
      "authType" : "ApiKey",
      "category" : "AzureOpenAI",
      "credentials" : {
        "key" : var.openai_key
      }
      "target" : "https://${var.openai_name}.openai.azure.com/",
      "isSharedToAll" : true,
      "metadata" : {
        "ApiType" : "AzureOpenAI"
      }
      "sharedUserList" : []
    }
  }
}
*/

# --- This module creates a ai search connection resource --- #
resource "azapi_resource" "cogsrchconn" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview"
  name      = "cogsrchconn"
  parent_id = azapi_resource.this.id
  body = {
    "properties" : {
      "authType" : "ApiKey",
      "category" : "CognitiveSearch",
      "credentials" : {
        "key" : var.search_admin_key
      }
      "target" : "https://${var.search_name}.search.windows.net",
      "isSharedToAll" : true,
      "metadata" : {
        "ApiType" : "CognitiveSearch"
      }
      "sharedUserList" : []
    }
  }
}

# --------- This module creates a private endpoints needed for ai studio and project ----------- #
data "azurerm_private_dns_zone" "ml" {
  provider            = azurerm.platform
  name                = var.private_endpoints.privateDnsZoneName[0]
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_private_dns_zone" "nb" {
  provider            = azurerm.platform
  name                = var.private_endpoints.privateDnsZoneName[1]
  resource_group_name = var.private_dns_zone_resource_group_name
}

resource "azurerm_private_endpoint" "this" {
  provider            = azurerm.platform
  name                = var.private_endpoints.privateEndpointName
  location            = var.location
  resource_group_name = var.private_endpoints.resourceGroupName
  subnet_id           = var.compute_subnet_id

  private_service_connection {
    name                           = var.private_endpoints.privateEndpointName
    private_connection_resource_id = azapi_resource.this.id
    is_manual_connection           = false
    subresource_names              = [var.private_endpoints.privateEndpointGroupId]
  }

  private_dns_zone_group {
    name = var.private_endpoints.privateEndpointGroupId
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.ml.id,
      data.azurerm_private_dns_zone.nb.id
    ]
  }
}

resource "azurerm_role_assignment" "rbac" {
  count                = length(var.user_principal_ids)
  scope                = azapi_resource.this.id
  role_definition_name = "Azure AI Developer"
  principal_id         = var.user_principal_ids[count.index]
}

