resource "azurerm_resource_group" "network_rg" {
    name        = "core"
    location    = var.loc
    tags        = var.tags 
}

resource "azurerm_virtual_network" "core_network" {
    name                = "core"
    resource_group_name = azurerm_resource_group.network_rg.name
    location            = azurerm_resource_group.network_rg.location
    address_space        = ["10.0.0.0/16"]
    dns_servers         = ["1.1.1.1", "1.0.0.1"]

    subnet {
        name            = "NGatewaySubnet"
        address_prefix   = "10.0.0.0/24"
    }

    subnet {
        name            = "training"
        address_prefix   = "10.0.1.0/24"
    }

    subnet {
        name            = "dev"
        address_prefix   = "10.0.2.0/24"
    }

    tags    = azurerm_resource_group.network_rg.tags
}

resource "azurerm_public_ip" "vpngw" {
    name                = "vpnGatewayPublicIp"
    resource_group_name = azurerm_resource_group.network_rg.name
    location            = azurerm_resource_group.network_rg.location
    tags                = azurerm_resource_group.network_rg.tags
    
    allocation_method   = "Dynamic"

}

# resource "azurerm_virtual_network_gateway" "vpngw" {
#   name                = "vpnGateway"
#   location            =  azurerm_resource_group.network_rg.location
#   resource_group_name =  azurerm_resource_group.network_rg.name
#   tags                =  azurerm_resource_group.network_rg.tags
#   type     = "Vpn"
#   vpn_type = "RouteBased"
#   active_active = false
#   enable_bgp    = false
#   sku           = "Basic"
#   ip_configuration {
#     name                          = "vpnGwConfig1"
#     public_ip_address_id          = azurerm_public_ip.vpngw.id
#     private_ip_address_allocation = "Static"
#     subnet_id                     = azurerm_subnet.gw.id
#   }
# }

