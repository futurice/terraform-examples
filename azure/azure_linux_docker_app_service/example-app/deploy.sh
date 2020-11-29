#!/bin/bash

RG_NAME=$1
APP_SERVICE_NAME=$2
ACR_URI=$3.azurecr.io
TAG=$4

FX_Version="Docker|"$ACR_URI"/"nodeapp:$TAG
WEBAPP_ID=$(az webapp show -g "$RG_NAME" -n "$APP_SERVICE_NAME" --query id --output tsv)"/config/web"
az resource update --ids "$WEBAPP_ID" --set "properties.linuxFxVersion=$FX_Version" -o none --force-string
