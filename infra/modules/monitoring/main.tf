# 1. Kho lưu trữ nhật ký tập trung (Log Analytics Workspace)
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 2. Hệ thống theo dõi hiệu năng ứng dụng (Application Insights)
resource "azurerm_application_insights" "appinsights" {
  name                = "appi-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "Node.JS"
}

# 3. Danh bạ người nhận cảnh báo khẩn cấp (Action Group)
resource "azurerm_monitor_action_group" "ag_devops" {
  name                = "ag-${var.project_name}-oncall"
  resource_group_name = var.resource_group_name
  short_name          = "DevOpsAlert"

  email_receiver {
    name                    = "SendToDevOpsEngineer"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

# 4. Còi báo động tự động: Kích hoạt ngay lập tức nếu Web App trả về lỗi máy chủ (HTTP 5xx)
resource "azurerm_monitor_metric_alert" "alert_http5xx" {
  name                = "alert-${var.project_name}-http5xx-critical"
  resource_group_name = var.resource_group_name
  scopes              = [var.webapp_id]
  description         = "CẢNH BÁO KHẨN: Hệ thống OmniPOS đang gặp lỗi máy chủ HTTP 5xx!"
  severity            = 1 # Mức độ 1: Nghiêm trọng (Critical)
  frequency           = "PT1M" # Quét kiểm tra mỗi 1 phút
  window_size         = "PT5M" # Khung thời gian đánh giá 5 phút

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0 # Chỉ cần có từ 1 lỗi 5xx trở lên là hú còi ngay
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag_devops.id
  }
}   