# Khởi tạo Giỏ 2: Chứa toàn bộ hạ tầng vận hành của doanh nghiệp
resource "azurerm_resource_group" "rg_main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    Project     = "OmniPOS-Enterprise"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 1. Lắp ghép Khối Mạng (Module Networking)
module "networking" {
  source              = "./modules/networking"
  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.rg_main.location
  resource_group_name = azurerm_resource_group.rg_main.name
}

# 2. Lắp ghép Khối Bảo mật & Dữ liệu (Nhận cáp từ Module Networking)
module "security_data" {
  source              = "./modules/security_data"
  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.rg_main.location
  resource_group_name = azurerm_resource_group.rg_main.name

  # Đấu nối ID mạng từ output của module networking sang input của module security_data
  vnet_id             = module.networking.vnet_id
  data_subnet_id      = module.networking.data_subnet_id
}
# 3. Lắp ghép Khối Máy chủ Ứng dụng (Nhận cáp từ cả Đội Mạng và Đội Bảo Mật)
module "compute" {
  source              = "./modules/compute"
  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.rg_main.location
  resource_group_name = azurerm_resource_group.rg_main.name

  # Cắm vào Subnet Ứng dụng (10.0.1.0/24)
  app_subnet_id       = module.networking.app_subnet_id

  # Nhận thông tin ACR, Key Vault và SQL để cấp quyền tự động
  acr_id              = module.security_data.acr_id
  acr_login_server    = module.security_data.acr_login_server
  key_vault_id        = module.security_data.key_vault_id
  sql_server_fqdn     = module.security_data.sql_server_fqdn
}