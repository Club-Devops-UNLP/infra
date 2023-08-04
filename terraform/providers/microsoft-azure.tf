## Base provider configuration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id            = var.subscription_id
  client_id                  = var.client_id
  client_secret              = var.client_secret
  tenant_id                  = var.tenant_id
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
}

resource "azurerm_resource_group" "club-devops" {
  name     = "${var.prefix}-resources"
  location = "eastus"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.club-devops.location
  resource_group_name = azurerm_resource_group.club-devops.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.club-devops.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.club-devops.location
  resource_group_name = azurerm_resource_group.club-devops.name

  ip_configuration {
    name                          = "club-devops-ip"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                             = "${var.prefix}-vm"
  location                         = azurerm_resource_group.club-devops.location
  resource_group_name              = azurerm_resource_group.club-devops.name
  network_interface_ids            = [azurerm_network_interface.main.id]
  vm_size                          = "B1s"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "club-devops-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "club-devops"
    admin_username = "adminuser"
    admin_password = "Password1234"
  }

  tags = {
    name        = "club-devops"
    environment = "staging"
  }
}

resource "azurerm_ssh_public_key" "ssh_key" {
  name                = "club-devops-ssh-key"
  resource_group_name = azurerm_resource_group.club-devops.name
  location            = azurerm_resource_group.club-devops.location
  public_key          = var.azure_key_pair_public_key
}
