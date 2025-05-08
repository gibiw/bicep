#!/bin/bash

# Azure CLI script to deploy Azure infrastructure using Bicep

# Parameters
resourceGroupName="rg-avd-demo"
location="eastus"
deploymentName="avd-deployment"
bicepFile="main.bicep"

# Login to Azure (uncomment if not already logged in)
# az login

# Create or update resource group
echo "Creating or updating resource group: $resourceGroupName"
az group create --name $resourceGroupName --location $location

# Deploy Bicep template
echo "Deploying Bicep template..."
az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file $bicepFile \
  --parameters @resourceGroup.parameters.json \
  --parameters @virtualNetwork.parameters.json \
  --parameters @hostPool.parameters.json

echo "Deployment completed."
