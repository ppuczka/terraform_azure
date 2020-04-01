provider "azurerm" {
    version = "~>1.44.0"

    subscription_id = "0ad5ac4a-b031-42a2-9fe5-5feb754f1822"

    
}

resource "azurerm_resource_group" "rg_tutorial_1" {
    name = "tutorial_1"
    location = "North Europe"

    tags = {
        Environment = "Terraform Getting Started"
        Team = "DevOps_Workshop"
    }
  
}
