terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    modtm = {
      source  = "Azure/modtm"
      version = ">= 0.1.8, < 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  subscription_id = "{}"
  tenant_id       = "{}"
  client_id       = "{}"
  client_secret   = "{}"
  features {
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

}


provider "azurerm" {
  alias           = "analytics"
  subscription_id = "{}"
  tenant_id       = "{}"
  client_id       = "{}"
  client_secret   = "{}"
  features {
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

}

provider "azurerm" {
  alias           = "platform"
  subscription_id = "{}"
  tenant_id       = "{}"
  client_id       = "{}"
  client_secret   = "{}"
  features {
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

}
