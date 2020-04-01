provider "azurerm" {
  version         = "~>1.44.0"
  subscription_id = ""
  tenant_id       = ""
}
provider "azuread" {
  version = "~>0.6.0"
}
terraform {
    backend "azurerm" {
      storage_account_name = "mytfaccount"
      container_name       = "mytfcontainer"
      key                  = "prod.terraform.mytfcontainer"
      access_key = ""

      # rather than defining this inline, the Access Key can also be sourced
      # from an Environment Variable - more information is available below.
      
    }
}
data "azurerm_client_config" "current" {}
