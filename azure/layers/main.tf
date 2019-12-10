provider "azuread" {
  version = "=0.7.0"
}

provider "random" {
  version = "=2.2.1"
}

provider "null" {
  version = "=2.1.2"
}

resource "azurerm_resource_group" "network" {
  name     = "${var.resource_name_prefix}-network-rgroup"
  location = var.location
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.resource_name_prefix}-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.137.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_name_prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.network.name
  resource_group_name  = azurerm_resource_group.network.name
  address_prefix       = "10.137.1.0/24"
  service_endpoints    = ["Microsoft.KeyVault"]

  lifecycle {
    ignore_changes = [
      network_security_group_id,
      route_table_id
    ]
  }
}

resource "azurerm_resource_group" "storage" {
  name     = "${var.resource_name_prefix}-storage-rgroup"
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                      = "${var.resource_name_prefix}storage"
  resource_group_name       = azurerm_resource_group.storage.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "storage" {
  name                  = "${var.resource_name_prefix}container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "a_file" {
  name                   = "hello.txt"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.storage.name
  type                   = "Block"
  source_content         = "Hello, Blob!"
}
