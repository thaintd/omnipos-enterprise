variable "project_name" {
  description = "Tên dự án chuẩn"
  type        = string
  default     = "omnipos"
}

variable "environment" {
  description = "Môi trường vận hành"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Khu vực Ấn Độ"
  type        = string
  default     = "indiasouthcentral"
}