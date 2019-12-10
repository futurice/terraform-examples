#!/bin/sh
# Usage: sh create.sh [options_for_terraform_apply]
# options eg. -auto-approve -var resource_name_prefix=${USER}

set -e

#terraform apply "$@" -target null_resource.service_principal_layer
terraform apply "$@" -target null_resource.resource_group_layer
terraform apply "$@"  -target null_resource.network_layer
terraform apply "$@" -target null_resource.subnet_layer
terraform apply "$@" -target null_resource.monitoring_layer
terraform apply "$@" -target null_resource.storage_layer
terraform apply "$@"
