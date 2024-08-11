## Create Diagnostic Settings for input resources
## This module creates diagnostic settings for the OpenAI account for now

resource "azurerm_monitor_diagnostic_setting" "setting" {
  for_each                       = var.diagnostic_setting
  name                           = each.value.name
  target_resource_id             = var.openai_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  partner_solution_id            = each.value.partner_solution_id
  storage_account_id             = var.storage_account_id

  dynamic "enabled_log" {
    for_each = try(each.value.audit_log_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "Audit"
    }
  }
  dynamic "enabled_log" {
    for_each = try(each.value.request_response_log_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "RequestResponse"
    }
  }
  dynamic "enabled_log" {
    for_each = try(each.value.trace_log_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "Trace"
    }
  }
  dynamic "metric" {
    for_each = try(each.value.metric_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "AllMetrics"
    }
  }
}
