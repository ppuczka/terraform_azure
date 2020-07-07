provider "azurerm" {
    version = "~>2.0"
   
    subscription_id = var.subscription
    tenant_id       = var.tenant

    features {

    }
}