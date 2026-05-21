# VM
resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = "${local.project}-${local.env}-bastion"
  location              = local.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.bastion.id]
  size                  = "Standard_B1ms"
  admin_username        = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.key_pair_pub
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  custom_data = base64encode(file("files/bastion/startup_scripts/template.tftpl"))
}

# Network Interface
resource "azurerm_network_interface" "bastion" {
  name                = "${local.project}-${local.env}-bastion-nic"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.main.name
  ip_configuration {
    name                          = "bastion-ip"
    subnet_id                     = azurerm_subnet.bastion.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

# NSG
resource "azurerm_network_security_group" "bastion" {
  name                = "${local.project}-${local.env}-bastion-nic-nsg"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "tmp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = local.ips
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

# Azure Monitor Agent
resource "azurerm_virtual_machine_extension" "bastion_monitor_agent" {
  name                       = "${local.project}-${local.env}-bastion-monitor-agent"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_linux_virtual_machine.bastion.id
}
