/*
    You may need service principals for eg. managing access to Key Vault.
    However, that requires privileges to manage AD, which is outside of focus of this example.

resource "null_resource" "service_principal_layer" {
  provisioner "local-exec" {
    command = "echo === Created all Service Principals"
  }

  depends_on = [
    azuread_service_principal.keyvault_sp,
    azuread_service_principal_password.keyvault_sp_password
  ]
}
*/

resource "null_resource" "resource_group_layer" {
  provisioner "local-exec" {
    command = "echo === Created all resource groups"
  }

  depends_on = [
    # null_resource.service_principal_layer,
    azurerm_resource_group.network,
    azurerm_resource_group.storage
  ]
}

resource "null_resource" "network_layer" {
  provisioner "local-exec" {
    command = "echo === Created all virtual networks"
  }

  depends_on = [
    null_resource.resource_group_layer,
    azurerm_virtual_network.network
  ]
}

resource "null_resource" "subnet_layer" {
  provisioner "local-exec" {
    command = "echo === Created all subnets"
  }

  depends_on = [
    null_resource.network_layer,
    azurerm_subnet.subnet
  ]
}

resource "null_resource" "monitoring_layer" {
  provisioner "local-exec" {
    command = "echo === Created monitoring components"
  }

  depends_on = [
    null_resource.subnet_layer,
    # monitoring is a bit out of scope, but it would go here
  ]
}

resource "null_resource" "storage_layer" {
  provisioner "local-exec" {
    command = "echo === Created storages"
  }
  depends_on = [
    null_resource.monitoring_layer,
    azurerm_storage_account.storage
  ]
}

/*
Resources outside layers can be created by not targeting anything
once the layers have been created.

Resources can use depends_on to ensure associated layers have been created for them.
*/
