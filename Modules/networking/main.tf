# ============================================================
# Networking Module - VNet, Subnets, NSGs
# ============================================================

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Subnet: System node pool (zone 1)
resource "azurerm_subnet" "aks_system" {
  name                 = "${var.vnet_name}-system-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_system_subnet_cidr]
}

# Subnet: App node pool (zone 2)
resource "azurerm_subnet" "aks_app" {
  name                 = "${var.vnet_name}-app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_app_subnet_cidr]
}

# Subnet: Ingress / Load Balancer
resource "azurerm_subnet" "ingress" {
  name                 = "${var.vnet_name}-ingress-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.ingress_subnet_cidr]
}

# NSG: System node pool
resource "azurerm_network_security_group" "aks_system" {
  name                = "${var.vnet_name}-system-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.ingress_subnet_cidr
    destination_address_prefix = var.aks_system_subnet_cidr
  }

  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.ingress_subnet_cidr
    destination_address_prefix = var.aks_system_subnet_cidr
  }

  security_rule {
    name                       = "deny-direct-internet"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = var.aks_system_subnet_cidr
  }
}

# NSG: App node pool
resource "azurerm_network_security_group" "aks_app" {
  name                = "${var.vnet_name}-app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-internal-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.vnet_address_space
    destination_address_prefix = var.aks_app_subnet_cidr
  }

  security_rule {
    name                       = "deny-direct-internet"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = var.aks_app_subnet_cidr
  }
}

# NSG: Ingress subnet (public-facing)
# checkov:skip=CKV_AZURE_160: Port 80 is required for HTTP-to-HTTPS redirect at the ingress controller layer
resource "azurerm_network_security_group" "ingress" {
  name                = "${var.vnet_name}-ingress-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = var.ingress_subnet_cidr
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = var.ingress_subnet_cidr
  }
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "aks_system" {
  subnet_id                 = azurerm_subnet.aks_system.id
  network_security_group_id = azurerm_network_security_group.aks_system.id
}

resource "azurerm_subnet_network_security_group_association" "aks_app" {
  subnet_id                 = azurerm_subnet.aks_app.id
  network_security_group_id = azurerm_network_security_group.aks_app.id
}

resource "azurerm_subnet_network_security_group_association" "ingress" {
  subnet_id                 = azurerm_subnet.ingress.id
  network_security_group_id = azurerm_network_security_group.ingress.id
}
