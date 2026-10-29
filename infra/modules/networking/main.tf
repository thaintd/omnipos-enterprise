# 1. Mạng ảo lõi (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# 2. Tầng Ứng dụng (App Subnet) - Uỷ quyền cho App Service cắm vào
resource "azurerm_subnet" "snet_app" {
  name                 = "snet-app-tier"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "appservice-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# 3. Tầng Dữ liệu & Bảo mật (Data Subnet) - Nơi đặt Private Endpoint cho DB, ACR, KeyVault
resource "azurerm_subnet" "snet_data" {
  name                 = "snet-data-tier"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 4. Tường lửa lớp mạng (Network Security Group - NSG)
resource "azurerm_network_security_group" "nsg_data" {
  name                = "nsg-${var.project_name}-data-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Luật số 1 (Ưu tiên 100): Chỉ cho phép Tầng Ứng dụng (10.0.1.0/24) gọi xuống Tầng Dữ liệu (10.0.2.0/24)
  security_rule {
    name                       = "Allow-AppSubnet-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "1433"] # Cổng 443 (ACR/KeyVault) và 1433 (SQL Server)
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }

  # Luật số 2 (Ưu tiên 200): Chặn đứng mọi kết nối từ Internet vào Tầng Dữ liệu
  security_rule {
    name                       = "Deny-Internet-Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# 5. Gắn (Associate) Tường lửa NSG trực tiếp vào cổng của Tầng Dữ liệu
resource "azurerm_subnet_network_security_group_association" "data_nsg_assoc" {
  subnet_id                 = azurerm_subnet.snet_data.id
  network_security_group_id = azurerm_network_security_group.nsg_data.id
}