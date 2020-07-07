variable "location" {}

variable "subscription_id" {}

variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = string
    description = "Password must meet Azure complexity requirements"
}

variable "prefix" {
    type = string
    default = "my"
}

variable "tags" {
    type = map

    default = {
        Environment = "Terraform GS"
        Dept = "Engineering"
  }
}

variable "sku" {
    default = {
        westeurope  = "7.5"
        northeurope = "6.5"
    }
}

