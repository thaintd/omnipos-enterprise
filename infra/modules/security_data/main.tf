# Lấy thông tin tài khoản Azure hiện tại (để cấp quyền Key Vault)
data "azurerm_client_config" "current" {}

# Sinh chuỗi 5 ký tự ngẫu nhiên (vì tên ACR, SQL, KeyVault phải là duy nhất trên toàn cầu)
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

# ==============================================================================
# 1. KHO CHỨA CONTAINER (AZURE CONTAINER REGISTRY - ACR)
# ==============================================================================
resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project_name}${var.environment}${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false # CHUẨN BẢO MẬT: Tắt tài khoản Admin dùng mật khẩu tĩnh
}

# ==============================================================================
# 2. KÉT SẮT MẬT KHẨU (AZURE KEY VAULT) & PRIVATE ENDPOINT
# ==============================================================================
resource "azurerm_key_vault" "kv" {
  name                          = "kv-${var.project_name}-${random_string.suffix.result}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true  # CHUẨN ENTERPRISE: Phân quyền bằng RBAC thay vì Access Policy cũ
  public_network_access_enabled = false # CẤM truy cập từ Internet
   purge_protection_enabled     = false # Cho phép xóa sạch khi chạy terraform destroy
}

# Danh bạ DNS nội bộ cho Key Vault
resource "azurerm_private_dns_zone" "dns_kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_kv" {
  name                  = "link-dns-kv"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_kv.name
  virtual_network_id    = var.vnet_id
}

# Đường hầm Private Endpoint cắm Key Vault vào snet-data-tier
resource "azurerm_private_endpoint" "pe_kv" {
  name                = "pe-kv-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.data_subnet_id

  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_kv.id]
  }
}

# ==============================================================================
# 3. CƠ SỞ DỮ LIỆU ĐƠN HÀNG (AZURE SQL SERVER & DB) & PRIVATE ENDPOINT
# ==============================================================================
# Tự động sinh mật khẩu SQL siêu mạnh dài 20 ký tự (Không ai biết, kể cả bạn)
resource "random_password" "sql_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_mssql_server" "sql" {
  name                          = "sql-${var.project_name}-${random_string.suffix.result}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = "omniposadmin"
  administrator_login_password  = random_password.sql_password.result
  public_network_access_enabled = false # CẤM truy cập từ Internet
}

resource "azurerm_mssql_database" "db" {
  name      = "db-omnipos-orders"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic" # Gói rẻ nhất cho môi trường Lab/Dev (~120k/tháng, xóa theo giờ)
}

# Danh bạ DNS nội bộ cho SQL Server
resource "azurerm_private_dns_zone" "dns_sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_sql" {
  name                  = "link-dns-sql"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_sql.name
  virtual_network_id    = var.vnet_id
}

# Đường hầm Private Endpoint cắm SQL Server vào snet-data-tier
resource "azurerm_private_endpoint" "pe_sql" {
  name                = "pe-sql-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.data_subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_sql.id]
  }
}