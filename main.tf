resource "azurerm_resource_group" "lab-rg" {
  name     = "lab-rg"
  location = "UK South"
}


resource "azurerm_network_security_group" "lab-net-nsg" {
  name                = "lab-network-security-group"
  location            = azurerm_resource_group.lab-rg.location
  resource_group_name = azurerm_resource_group.lab-rg.name
}



resource "azurerm_virtual_network" "lab-vnet" {
  name                = "lab-network"
  location            = azurerm_resource_group.lab-rg.location
  resource_group_name = azurerm_resource_group.lab-rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}


resource "azurerm_subnet" "lab-mgmt-subnet" {
  name                 = "lab-mgmt-subnet"
  resource_group_name  = azurerm_resource_group.lab-rg.name
  virtual_network_name = azurerm_virtual_network.lab-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_subnet" "lab-app-subnet" {
  name                 = "lab-app-subnet"
  resource_group_name  = azurerm_resource_group.lab-rg.name
  virtual_network_name = azurerm_virtual_network.lab-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_subnet" "lab-db-subnet" {
  name                 = "lab-db-subnet"
  resource_group_name  = azurerm_resource_group.lab-rg.name
  virtual_network_name = azurerm_virtual_network.lab-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}


resource "azurerm_subnet_network_security_group_association" "lab-nsg-association" {
  subnet_id                 = azurerm_subnet.lab-app-subnet.id
  network_security_group_id = azurerm_network_security_group.lab-net-nsg.id
}


resource "azurerm_route_table" "lab-rt" {
  name                          = "lab-route-table"
  location                      = azurerm_resource_group.lab-rg.location
  resource_group_name           = azurerm_resource_group.lab-rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.96.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "Production"
  }
}


resource "azurerm_subnet_route_table_association" "lab-rt-association" {
  subnet_id      = azurerm_subnet.lab-app-subnet.id
  route_table_id = azurerm_route_table.lab-rt.id
}



