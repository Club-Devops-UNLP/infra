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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
  ####################
  # TODO: Why is throwing an error when using the following variables?
  # client_id                  = var.client_id 
  # client_secret              = var.client_secret
  ####################
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

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.club-devops.name
  location            = azurerm_resource_group.club-devops.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.club-devops.location
  resource_group_name = azurerm_resource_group.club-devops.name

  ip_configuration {
    name                          = "club-devops-ip"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_virtual_machine" "main" {
  name                             = "${var.prefix}-vm"
  location                         = azurerm_resource_group.club-devops.location
  resource_group_name              = azurerm_resource_group.club-devops.name
  network_interface_ids            = [azurerm_network_interface.main.id]
  vm_size                          = "Standard_B1ls"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
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
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    name        = "club-devops"
    environment = "staging"
  }

}

resource "azurerm_virtual_machine_extension" "jit_vm_access" {
  name                       = "JIT-VM-Access"
  virtual_machine_id         = azurerm_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureJitAccess"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  settings = jsondecode({
    "durationInSeconds" = 3600
  })
}

resource "azurerm_ssh_public_key" "ssh_key" {
  name                = "club-devops-ssh-key"
  resource_group_name = azurerm_resource_group.club-devops.name
  location            = azurerm_resource_group.club-devops.location
  public_key          = var.azure_key_pair_public_key
}
