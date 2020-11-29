# Configure the Azure Provider
provider "azurerm" {
  version                    = "= 2.37.0"
  skip_provider_registration = true
  features {}
}

provider "random" {
  version = "~> 2.3"
}

provider "template" {
  version = "~> 2.1"
}
