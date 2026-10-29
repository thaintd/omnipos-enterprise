variable "project_name" {
  description = "Tên định danh dự án"
  type        = string
}

variable "environment" {
  description = "Môi trường triển khai (prod, staging, dev)"
  type        = string
}

variable "location" {
  description = "Khu vực máy chủ Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Tên Giỏ 2 (Resource Group chứa hạ tầng ứng dụng)"
  type        = string
}