provider "azurerm" {
    version = "~>2.0"
   
    subscription_id = var.subscription
    tenant_id       = var.tenant

    features {

    }
}

resource "random_string" "webapprnd" {

    lower   = true
    number  = true
    upper   = false
    special = false
}

resource "azurerm_resource_group" "lab2" {
    name = var.name
    location = var.loc
    tags = var.tags
}

resource "azurerm_storage_account" "lab2sa" {
    name                      = "przemek${random_string.webapprnd.result}"
    resource_group_name       =  azurerm_resource_group.lab2.name
    location                  =  azurerm_resource_group.lab2.location
    account_kind              = "StorageV2"
    account_tier              = "Standard"
    account_replication_type  = "LRS"
    access_tier               = "Cool"

}
