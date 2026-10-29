output "webapp_id" {
  value = azurerm_linux_web_app.webapp_prod.id
}

output "webapp_name" {
  value = azurerm_linux_web_app.webapp_prod.name
}

output "production_url" {
  value = "https://${azurerm_linux_web_app.webapp_prod.default_hostname}"
}

output "staging_url" {
  value = "https://${azurerm_linux_web_app_slot.webapp_staging.default_hostname}"
}