resource "azurerm_resource_group" "rg" {
    name        = "core"
    location    = var.loc
    tags        = var.tags 
}

resource "public_ip" "ip" {
    
}