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

resource "azurerm_virtual_network" "vnet_tutorial" {
    name            = "myTutorialVnet"
    address_space   = ["10.0.0.0./16"]
    location        = "North Europe"
    resource_group_name = azurerm_resource_group.rg_tutorial_1.name
}

resource "azurerm_subnet" "subnet" {
    name                    = "myTutorialSubnet"
    resource_group_name     = azurerm_resource_group.rg_tutorial_1.name
    virtual_network_name    = azurerm_virtual_network.vnet_tutorial.name
    address_prefix          = "10.0.1.0/24"  
}   

resource "azurerm_public_ip" "publicip" {
    name                = "${var.resource_prefix}TFPublicIP"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_tutorial_1.name
    allocation_method   = "Static"
} 

resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSG"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.rg_tutorial_1.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "myNIC"
  location                  = "North Europe"
  resource_group_name       = azurerm_resource_group.rg_tutorial_1.name
  network_security_group_id = azurerm_network_security_group.nsg.id

  ip_configuration {
    name                          = "myNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "myTFVM"
  location              = "North Europe"
  resource_group_name   = azurerm_resource_group.rg_tutorial_1.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }


  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myTFVM"
    admin_username = "plankton"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false

  }
}
