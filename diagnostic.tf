# Configuration to send diagnostic logs to Log Analytics workspace
resource "azurerm_monitor_diagnostic_setting" "la" {
  for_each                   = length(var.log_analytics) > 0 ? var.log_analytics : {}
  name                       = "${local.ladiag_settings_name}-${each.value.la_workspace_name}"
  target_resource_id         = azurerm_cosmosdb_account.this.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.this[each.key].id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "PartitionKeyStatistics"
  }

  enabled_log {
    category = "ControlPlaneRequests"
  }

  dynamic "enabled_log" {
    for_each = local.diag_logs
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
  }
}

# Configuration to send diagnostic logs to Storage Account 
resource "azurerm_monitor_diagnostic_setting" "sa" {
  for_each           = length(var.storage_account) > 0 ? var.storage_account : {}
  name               = "${local.sadiag_settings_name}-${each.value.storage_account_name}"
  target_resource_id = azurerm_cosmosdb_account.this.id
  storage_account_id = data.azurerm_log_analytics_workspace.this[each.key].id

  enabled_log {
    category = "DataPlaneRequests"
    retention_policy {
      enabled = each.value.enable_logs_retention_policy
      days    = each.value.logs_retention_days
    }
  }

  enabled_log {
    category = "PartitionKeyStatistics"
    retention_policy {
      enabled = each.value.enable_logs_retention_policy
      days    = each.value.logs_retention_days
    }
  }

  enabled_log {
    category = "ControlPlaneRequests"
    retention_policy {
      enabled = each.value.enable_logs_retention_policy
      days    = each.value.logs_retention_days
    }
  }

  dynamic "enabled_log" {
    for_each = local.diag_logs
    content {
      category = enabled_log.value
      retention_policy {
        enabled = each.value.enable_logs_retention_policy
        days    = each.value.logs_retention_days
      }
    }
  }


  metric {
    category = "AllMetrics"
  }
}

# Configuration to send diagnostic logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "eh" {
  for_each                       = length(var.event_hub) > 0 ? var.event_hub : {}
  name                           = "${local.ehdiag_settings_name}-${each.value.event_hub_namespace_name}"
  target_resource_id             = azurerm_cosmosdb_account.this.id
  eventhub_authorization_rule_id = data.azurerm_eventhub_authorization_rule.this[each.key].id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "PartitionKeyStatistics"
  }

  enabled_log {
    category = "ControlPlaneRequests"
  }

  dynamic "enabled_log" {
    for_each = local.diag_logs
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
  }
}
