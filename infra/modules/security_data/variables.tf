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

variable "vnet_id" {
  description = "ID của mạng VNet để gắn danh bạ Private DNS"
  type        = string
}

variable "data_subnet_id" {
  description = "ID của Subnet dữ liệu (10.0.2.0/24) để cắm Private Endpoint"
  type        = string
}