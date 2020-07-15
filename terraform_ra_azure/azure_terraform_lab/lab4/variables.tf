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