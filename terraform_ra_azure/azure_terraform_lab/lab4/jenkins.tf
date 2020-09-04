terraform {

  backend "azurerm" {
    resource_group_name  = "terraformstate"
    storage_account_name = "tfstate8080"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"

  }
}
provider "azurerm" {
  version = "=2.24.0"
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = "devOpsLab"
  location = var.location

  tags = {
    environment = var.environment
  }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "devOpsLabVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = {
    environment = var.environment
  }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "devOpsLabSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "devOpsLabPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  allocation_method   = "Static"

  tags = {
    environment = "Terraform Demo"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "devOpsLabNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}

resource "azurerm_network_security_rule" "jenkins_ssl" {
  name                        = "jenkins"
  priority                    = 1100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  network_security_group_name = azurerm_network_security_group.myterraformnsg.name
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "devOpsLabNIC"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "devOpsLabNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = {
    environment = var.environment
  }
}

output "public_ip" { value = azurerm_public_ip.myterraformpublicip.ip_address }


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.myterraformgroup.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.myterraformgroup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

data "template_file" "docker" {
  template = file("custom_data/cloud-config.yml")
}

# Obtain SSL certificate from azure vault 

# data "azurerm_key_vault" "ppuczka_vault" {
#   name                = "ppuczka-vault"
#   resource_group_name = "vault"
# }

# data "azurerm_key_vault_secret" "jenkins_ssl_key" {
#   name         = "jenkins-keystorev2"
#   key_vault_id = data.azurerm_key_vault.ppuczka_vault.id
# }

# output "certificate_ssl" {
#   value = data.azurerm_key_vault_secret.jenkins_ssl_key
# }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                            = "jenkinsVm"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.myterraformgroup.name
  network_interface_ids           = [azurerm_network_interface.myterraformnic.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.docker.rendered)

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
  
  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.myterraformpublicip.ip_address
      user        = "azureuser"
      private_key = tls_private_key.example_ssh.private_key_pem
    }

    inline = [
      "sudo mkdir /home/azureuser/jenkins_home",
      "sudo mkdir /home/azureuser/jenkins_home/keys/"
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.myterraformpublicip.ip_address
      user        = "azureuser" 
      private_key = tls_private_key.example_ssh.private_key_pem
    }

    source     = "jenkins_keystore.jks"
    destination = "/tmp/jenkins_keystore.jks"
  }


   provisioner "remote-exec" {

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.myterraformpublicip.ip_address
      user        = "azureuser"
      private_key = tls_private_key.example_ssh.private_key_pem
    }

    inline = [
      "echo starting docker",
      #"sudo dockerd",
      "sudo cp /tmp/jenkins_keystore.jks /home/azureuser/jenkins_home/keys",
      "echo pulling jenkins container",
      "sleep 20;sudo docker pull jenkins/jenkins",
      "sleep 10,sudo chown -R 1000:1000 /home/azureuser/jenkins_home", 
      "sleep 20;sudo docker run -v /home/azureuser/jenkins_home:/var/jenkins_home  -p 443:8443 -d jenkins/jenkins --httpPort=-1 --httpsPort=8443 --httpsKeyStore=/var/jenkins_home/keys/jenkins_keystore.jks --httpsKeyStorePassword=Myszaa89"
        # $ docker run -v /home/ubuntu/johndoe/jenkins:/var/jenkins_home -p 443:8443 jenkins --httpPort=-1 --httpsPort=8443 --httpsKeyStore=/var/jenkins_home/jenkins_keystore.jks --httpsKeyStorePassword=<keystore password>
    ]
  }

  tags = {
    environment = "Terraform Demo"
  }

}
