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

variable "webapp_id" {
  description = "ID của máy chủ App Service cần gắn camera giám sát"
  type        = string
}

variable "alert_email" {
  description = "Địa chỉ Email của Kỹ sư trực hệ thống nhận báo động"
  type        = string
}