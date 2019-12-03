# Terraform Azure Layers example

Azure resources may take a long time to create. Sometimes Terraform fails to spot that some resource actually requires another resource that has not been fully created yet. Layers help to ensure that all prerequisite resources for later ones are created before them.

## Try it out

```sh
az login
terraform init
sh create.sh -auto-approve -var resource_name_prefix=${USER}trylayers
```

## Clean up

```sh
sh destroy.sh ${USER}trylayers
```

## Files

- `create.sh` presents a simple hard-coded deployment run that ensures each layer is completed separately.
- `destroy.sh` takes a quick, resource-group based approach to wiping out the whole deployment.
- `layers.tf` lists each layer with associated dependencies.
- `main.tf` contains sample resources used on different layers.
- `variables.sh` declares associated variables with sane defaults.
