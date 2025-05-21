// main.bicep - Main deployment file for Azure Firewall
// Parameters for the entire deployment
@description('Location for all resources')
param location string = resourceGroup().location

@description('Name prefix for all resources')
param namePrefix string = 'fw'

@description('Tags for all resources')
param tags object = {
  environment: 'production'
  project: 'firewall-deployment'
}

// Parameters for virtual network
@description('Address space for the virtual network')
param vnetAddressPrefix string = '10.0.0.0/16'

// Parameters for Azure Firewall subnet
@description('Address prefix for Azure Firewall subnet')
param firewallSubnetPrefix string = '10.0.0.0/24'

// Parameters for Firewall configuration
@description('Name of the Azure Firewall')
param firewallName string = '${namePrefix}-firewall'

@description('Tier of Azure Firewall (Standard or Premium)')
@allowed([
  'Standard'
  'Premium'
])
param firewallTier string = 'Standard'

// Deploy virtual network with subnet
module networkModule 'modules/vnet/vnet.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnetName: '${namePrefix}-vnet'
    vnetAddressPrefix: vnetAddressPrefix
    firewallSubnetPrefix: firewallSubnetPrefix
    tags: tags
  }
}

// Deploy public IP address for Azure Firewall
module publicIpModule 'modules/publicIp/public-ip.bicep' = {
  name: 'publicIpDeployment'
  params: {
    location: location
    publicIpName: '${namePrefix}-firewall-pip'
    publicIpSku: 'Standard'
    publicIpAllocationMethod: 'Static'
    tags: tags
  }
}

// Deploy Azure Firewall
module firewallModule 'modules/firewall/firewall.bicep' = {
  name: 'firewallDeployment'
  params: {
    location: location
    firewallName: firewallName
    firewallTier: firewallTier
    vnetName: networkModule.outputs.vnetName
    publicIpId: publicIpModule.outputs.publicIpId
    tags: tags
  }
}

// Deploy rules for Azure Firewall
module firewallRulesModule 'modules/firewall/firewall-rules.bicep' = {
  name: 'firewallRulesDeployment'
  params: {
    firewallName: firewallName
  }
  dependsOn: [
    firewallModule
  ]
}

// Output information about deployed resources
output firewallName string = firewallModule.outputs.firewallName
output firewallId string = firewallModule.outputs.firewallId
output firewallPrivateIp string = firewallModule.outputs.firewallPrivateIp
output firewallPublicIp string = publicIpModule.outputs.publicIpAddress
