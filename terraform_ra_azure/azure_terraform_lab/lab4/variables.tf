variable "name" {
  default = "terraform-lab4"
}

variable "location" {
  default = "West Europe"
}

variable "environment" {
  default = "Terraform Lab"
}

variable "subscription" {
  description = "Azure secret subscription id"
}

variable "tenant" {
  description = "Azure secret tenant id"
}

variable "ARM_ACCES_KEY" {
  description = "Azure storage container key"
}