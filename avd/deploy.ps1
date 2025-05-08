# PowerShell script to deploy Azure infrastructure using Bicep

# Parameters
$resourceGroupName = "rg-avd-demo"
$location = "eastus"
$deploymentName = "avd-deployment"
$bicepFile = "main.bicep"

# Login to Azure (uncomment if not already logged in)
# Connect-AzAccount

# Create or update resource group
Write-Host "Creating or updating resource group: $resourceGroupName"
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Deploy Bicep template
Write-Host "Deploying Bicep template..."
New-AzResourceGroupDeployment `
  -Name $deploymentName `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile $bicepFile `
  -TemplateParameterFile "resourceGroup.parameters.json" `
  -TemplateParameterFile "virtualNetwork.parameters.json" `
  -TemplateParameterFile "hostPool.parameters.json"

Write-Host "Deployment completed."
