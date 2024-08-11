variable "resource_group_name" {
  default = "rg-ai-prod"
}
variable "location" {
  default = "eastus"
}
variable "storage_account_name" {
  default = "aaaorgaistoragen"
}

variable "container_names" {
  default = []
}

variable "keyvault_name" {
  default = "aaaorgkvn"
}

variable "log_name" {
  default = "aaaorg-log-studion"
}

variable "appi_name" {
  default = "aaaorg-appi-studion"
}

variable "acr_name" {
  default = "aaaorgacrn"
}

variable "search_name" {
  default = "aaaorgsearchn"
}

variable "search_partition_count" {
  default = 1
}

variable "search_replica_count" {
  default = 1
}

variable "search_sku" {
  default = "basic"
}

variable "semantic_search_sku" {
  default = "free"
}

variable "hosting_mode" {
  default = "default"
}

variable "mlw_hub_name" {
  default = "aaaorg-ai-studio"
}

variable "mlw_proj_name" {
  default = "aaaorg-ai-project"
}

variable "use_random_suffix" {
  default = true
}

variable "tags" {
  default = {
    terraform    = "true"
    plzcertified = "true"
  }
}

variable "private_dns_zone_resource_group_name" {
  default = "rg-dnszones"
}

variable "virtual_network_resource_group_name" {
  default = "rg-network"
}

variable "virtual_network_name" {
  default = "platformvneteastus"
}

variable "private_endpoints_subnet_name" {
  default = "default"
}

variable "enable_private_endpoints" {
  default = true
}

variable "openai_name" {
  default = "aaaorg-aoai"
}

variable "openai_private_endpoint_name" {
  default = "aaaorg-aoai-oai"
}

variable "openai_deployments" {
  default = {

    embeddings = {
      name = "text-embedding-ada-002"
      model = {
        format          = "OpenAI"
        name            = "text-embedding-ada-002"
        version         = "2"
        rai_policy_name = "Microsoft.Default"
      }
      sku = {
        name     = "Standard"
        capacity = 5
      }
    },
    gpt4turbo = {
      name = "gpt-4"
      model = {
        format          = "OpenAI"
        name            = "gpt-4"
        version         = "turbo-2024-04-09"
        rai_policy_name = "Microsoft.Default"
      }
      sku = {
        name     = "Standard"
        capacity = 10
      }
    }
  }
}

variable "contributor_principal_ids" {
  default = []
}

variable "user_principal_ids" {
  default = ["dfc3d2cb-c843-412f-acb4-e8706989aab2"]
}

variable "tenantid" {
  default = "8429325e-77e2-4bd9-9f1e-4be922d474df"
}


variable "diagnostic_setting" {
  type = map(object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    storage_account_id             = optional(string)
    partner_solution_id            = optional(string)
    audit_log_retention_policy = optional(object({
      enabled = optional(bool, true)
      days    = optional(number, 7)
    }))
    request_response_log_retention_policy = optional(object({
      enabled = optional(bool, true)
      days    = optional(number, 7)
    }))
    trace_log_retention_policy = optional(object({
      enabled = optional(bool, true)
      days    = optional(number, 7)
    }))
    metric_retention_policy = optional(object({
      enabled = optional(bool, true)
      days    = optional(number, 7)
    }))
  }))
  default = {
    logopenai = {
      name                           = "ailandingzone-diagnostic-setting-oai"
      log_analytics_destination_type = "Dedicated"
      eventhub_name                  = null
      eventhub_authorization_rule_id = null
      partner_solution_id            = null
      audit_log_retention_policy = {
        enabled = true
        days    = 7
      }
      trace_log_retention_policy            = null
      metric_retention_policy               = null
      request_response_log_retention_policy = null
    }
  }
}
