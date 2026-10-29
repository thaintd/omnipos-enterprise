output "resource_group_name" {
  value = azurerm_resource_group.rg_main.name
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "acr_login_server" {
  value = module.security_data.acr_login_server
}

output "sql_server_fqdn" {
  value = module.security_data.sql_server_fqdn
}

output "webapp_name" {
  value = module.compute.webapp_name
}

output "production_url" {
  value = module.compute.production_url
}

output "staging_url" {
  value = module.compute.staging_url
}