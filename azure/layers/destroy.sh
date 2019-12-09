#!/bin/sh
# Usage: [DRY_RUN=1] sh destroy.sh [resource_name_prefix]

PREFIX=${1:-trylayers}
RUN=${DRY_RUN:+echo}

# Remove each resource group, in reverse order of layers during create.

$RUN az group delete --yes -n ${PREFIX}-storage-rgroup
$RUN az group delete --yes -n ${PREFIX}-network-rgroup

# Delete here any resources that do not belong to above resource groups,
# ie. Service Principals.

# Finally tell Terraform that nothing exists anymore.
$RUN rm terraform.tfstate # please use shared statefile in real world
