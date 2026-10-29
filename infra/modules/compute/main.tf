# Sinh chuỗi ngẫu nhiên để tên miền Web App (.azurewebsites.net) không bị trùng trên toàn cầu
resource "random_string" "web_suffix" {
  length  = 5
  special = false
  upper   = false
}

# ==============================================================================
# 1. GÓI HẠ TẦNG PHẦN CỨNG (APP SERVICE PLAN - LINUX)
# ==============================================================================
resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1" # Gói Standard S1 mới hỗ trợ tính năng Staging Slot (Blue-Green)
}

# ==============================================================================
# 2. MÁY CHỦ ỨNG DỤNG CHÍNH (PRODUCTION WEB APP)
# ==============================================================================
resource "azurerm_linux_web_app" "webapp_prod" {
  name                      = "app-${var.project_name}-${var.environment}-${random_string.web_suffix.result}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.asp.id
  https_only                = true # Bắt buộc mã hóa HTTPS
  virtual_network_subnet_id = var.app_subnet_id # CẮM CHÂN VÀO MẠNG NỘI BỘ snet-app-tier

  # Bật Thẻ từ Định danh tự động (Managed Identity)
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                         = true # Giữ máy chủ luôn thức 24/7, không bị ngủ đông
    vnet_route_all_enabled            = true # Ép toàn bộ lưu lượng mạng đi qua VNet nội bộ
    container_registry_use_managed_identity = true # Dùng Thẻ từ để kéo Image từ ACR (Không cần mật khẩu)
    health_check_path                 = "/healthz" # Đường dẫn khám sức khỏe tự động
    health_check_eviction_time_in_min = 5

    # Lúc mới dựng hạ tầng, tạm thời chạy Image mẫu của Microsoft trong lúc chờ CI/CD ở Sprint 4
    application_stack {
      docker_image_name   = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }

  app_settings = {
    "WEBSITES_PORT"   = "3000"
    "ENVIRONMENT"     = "PRODUCTION"
    "ACR_SERVER"      = var.acr_login_server
    "SQL_SERVER_FQDN" = var.sql_server_fqdn
  }
}

# ==============================================================================
# 3. MÁY CHỦ PHỤ KIỂM THỬ (STAGING SLOT - PHỤC VỤ BLUE-GREEN DEPLOYMENT)
# ==============================================================================
resource "azurerm_linux_web_app_slot" "webapp_staging" {
  name                      = "staging"
  app_service_id            = azurerm_linux_web_app.webapp_prod.id
  https_only                = true
  virtual_network_subnet_id = var.app_subnet_id # Staging cũng cắm vào mạng nội bộ như Prod

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    vnet_route_all_enabled                  = true
    container_registry_use_managed_identity = true
    health_check_path                       = "/healthz"
    health_check_eviction_time_in_min       = 5

    application_stack {
      docker_image_name   = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }

  app_settings = {
    "WEBSITES_PORT"   = "3000"
    "ENVIRONMENT"     = "STAGING"
    "ACR_SERVER"      = var.acr_login_server
    "SQL_SERVER_FQDN" = var.sql_server_fqdn
  }
}

# ==============================================================================
# 4. CẤP QUYỀN KHÔNG MẬT KHẨU (RBAC ROLE ASSIGNMENTS)
# ==============================================================================
# 4.1. Cho phép máy PRODUCTION kéo Image từ kho ACR (Quyền: AcrPull)
resource "azurerm_role_assignment" "prod_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.webapp_prod.identity[0].principal_id
}

# 4.2. Cho phép máy STAGING kéo Image từ kho ACR (Quyền: AcrPull)
resource "azurerm_role_assignment" "staging_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app_slot.webapp_staging.identity[0].principal_id
}

# 4.3. Cho phép máy PRODUCTION đọc mật khẩu trong Key Vault
resource "azurerm_role_assignment" "prod_kv_reader" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.webapp_prod.identity[0].principal_id
}

# 4.4. Cho phép máy STAGING đọc mật khẩu trong Key Vault
resource "azurerm_role_assignment" "staging_kv_reader" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app_slot.webapp_staging.identity[0].principal_id
}