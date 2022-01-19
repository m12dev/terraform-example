# Set Allow IP
variable "current_ip" {
    type    = string
    default = "*"
}

# Get Random String
resource "random_string" "code" {
  length  = 5
  special = false
  upper   = false
}

resource "random_string" "disk_id" {
  length  = 32
  special = false
  upper   = false
}

resource "random_string" "passwd" {
  length  = 16
  special = false
  upper   = true
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "japaneast"

  tags = {
    make = "terraform"
  }
}

# Create a Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = "nsg-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    make = "terraform"
  }
}

# Create a Network Security Group Rule
resource "azurerm_network_security_rule" "example1" {
  name                        = "Port_22"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.current_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

resource "azurerm_network_security_rule" "example2" {
  name                        = "Port_80"
  priority                    = 1100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = var.current_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

# Create a Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    make = "terraform"
  }
}

# Create a Subnet
resource "azurerm_subnet" "example" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create a Public Ip
resource "azurerm_public_ip" "example" {
  name                = "pip-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Dynamic"
  domain_name_label   = "ex-${random_string.code.result}"

  tags = {
    make = "terraform"
  }
}

#Create a Network Interface
resource "azurerm_network_interface" "example" {
  name                = "nic-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "nic-ip-example"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }

  tags = {
    make = "terraform"
  }
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                            = "ex-${random_string.code.result}"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = "Standard_B1ls"
  admin_username                  = "ubuntu"
  admin_password                  = random_string.passwd.result
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  /*
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  */

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202201040"
  }

  custom_data = filebase64("./custom_data.sh")

  tags = {
    make = "terraform"
  }
}