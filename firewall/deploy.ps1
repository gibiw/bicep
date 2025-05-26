# deploy.ps1 - PowerShell script for deploying Azure Firewall with Bicep

# Parameters
$resourceGroupName = "rg-nyl-hub-networking-001"
$location = "eastus"  # Change to your desired region
$deploymentName = "firewall-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Create resource group if it doesn't exist
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating resource group '$resourceGroupName' in region '$location'..."
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}

# Deploy with Bicep
Write-Host "Starting Azure Firewall deployment..."
New-AzResourceGroupDeployment `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile "./main.bicep" `
    -location $location `
    -nameSuffix "hub-eastus-01" `
    -Verbose

Write-Host "Deployment completed."
