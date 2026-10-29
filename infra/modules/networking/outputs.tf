output "vnet_id" {
  description = "ID của mạng ảo VNet"
  value       = azurerm_virtual_network.vnet.id
}

output "app_subnet_id" {
  description = "ID của Subnet tầng ứng dụng"
  value       = azurerm_subnet.snet_app.id
}

output "data_subnet_id" {
  description = "ID của Subnet tầng dữ liệu"
  value       = azurerm_subnet.snet_data.id
}