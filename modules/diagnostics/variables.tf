variable "storage_account_id" {
  
}

variable "log_analytics_workspace_id" {
  
}

variable "diagnostic_setting" {
  type = map(object({
    name                           = string
//    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
//    storage_account_id             = optional(string)
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
  default     = {
    
  }
  description = <<-DESCRIPTION
  A map of objects that represent the configuration for a diagnostic setting."
  type = map(object({
    name                                  = (Required) Specifies the name of the diagnostic setting. Changing this forces a new resource to be created.
    log_analytics_workspace_id            = (Optional) (Optional) Specifies the resource id of an Azure Log Analytics workspace where diagnostics data should be sent.
    log_analytics_destination_type        = (Optional) Possible values are `AzureDiagnostics` and `Dedicated`. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy `AzureDiagnostics` table.
    eventhub_name                         = (Optional) Specifies the name of the Event Hub where diagnostics data should be sent.
    eventhub_authorization_rule_id        = (Optional) Specifies the resource id of an Event Hub Namespace Authorization Rule used to send diagnostics data.
    storage_account_id                    = (Optional) Specifies the resource id of an Azure storage account where diagnostics data should be sent.
    partner_solution_id                   = (Optional) The resource id of the market partner solution where diagnostics data should be sent. For potential partner integrations, click to learn more about partner integration.
    audit_log_retention_policy            = (Optional) Specifies the retention policy for the audit log. This is a block with the following properties:
      enabled                             = (Optional) Specifies whether the retention policy is enabled. If enabled, `days` must be a positive number.
      days                                = (Optional) Specifies the number of days to retain trace logs. If `enabled` is set to `true`, this value must be set to a positive number.
    request_response_log_retention_policy = (Optional) Specifies the retention policy for the request response log. This is a block with the following properties:
      enabled                             = (Optional) Specifies whether the retention policy is enabled. If enabled, `days` must be a positive number.
      days                                = (Optional) Specifies the number of days to retain trace logs. If `enabled` is set to `true`, this value must be set to a positive number.
    trace_log_retention_policy            = (Optional) Specifies the retention policy for the trace log. This is a block with the following properties:
      enabled                             = (Optional) Specifies whether the retention policy is enabled. If enabled, `days` must be a positive number.
      days                                = (Optional) Specifies the number of days to retain trace logs. If `enabled` is set to `true`, this value must be set to a positive number.
    metric_retention_policy               = (Optional) Specifies the retention policy for the metric. This is a block with the following properties:
      enabled                             = (Optional) Specifies whether the retention policy is enabled. If enabled, `days` must be a positive number.
      days                                = (Optional) Specifies the number of days to retain trace logs. If `enabled` is set to `true`, this value must be set to a positive number.
  }))
DESCRIPTION
  nullable    = false
}

variable "openai_account_id" {
  
}


variable "resource_group_name" {

}

variable "location" {
  
}