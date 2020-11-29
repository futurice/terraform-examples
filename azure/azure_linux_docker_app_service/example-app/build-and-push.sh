#!/bin/bash

TAG=$(date +%s)
ACR_URI=$1.azurecr.io
az acr login -n "$1"

docker build -t "$ACR_URI/nodeapp:$TAG" .

docker push "$ACR_URI/nodeapp:$TAG"

echo "TAGGED AS $TAG"
