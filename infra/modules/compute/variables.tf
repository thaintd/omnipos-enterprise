variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "app_subnet_id" {
  description = "ID của snet-app-tier (10.0.1.0/24) để cắm máy chủ Web vào mạng nội bộ"
  type        = string
}

variable "acr_id" {
  description = "ID của kho ACR để cấp quyền kéo Image (AcrPull)"
  type        = string
}

variable "acr_login_server" {
  description = "Địa chỉ máy chủ ACR (ví dụ: acromnipos...azurecr.io)"
  type        = string
}

variable "key_vault_id" {
  description = "ID của Key Vault để cấp quyền đọc mật khẩu"
  type        = string
}

variable "sql_server_fqdn" {
  description = "Tên miền nội bộ của SQL Server"
  type        = string
}