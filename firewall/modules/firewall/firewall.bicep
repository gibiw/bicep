// modules/firewall.bicep - Module for creating Azure Firewall

@description('Location for the resource')
param location string

@description('Name of the Azure Firewall')
param firewallName string

@description('Name of the virtual network')
param vnetName string

@description('ID of the public IP address')
param publicIpId string

@description('Tier of Azure Firewall (Standard or Premium)')
@allowed([
  'Standard'
  'Premium'
])
param firewallTier string = 'Standard'

@description('Tags for the resource')
param tags object = {}

// Get the existing virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: vnetName
}

// Get the existing Firewall subnet (must be named AzureFirewallSubnet)
resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  parent: vnet
  name: 'AzureFirewallSubnet'
}

// Create Azure Firewall Policy
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: '${firewallName}-policy'
  location: location
  tags: tags
  properties: {
    sku: {
      tier: firewallTier
    }
  }
}

// Create Azure Firewall
resource firewall 'Microsoft.Network/azureFirewalls@2021-08-01' = {
  name: firewallName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: firewallTier
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [
      {
        name: '${firewallName}-ipconfig'
        properties: {
          subnet: {
            id: firewallSubnet.id
          }
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
  }
}

// Output data
output firewallName string = firewall.name
output firewallId string = firewall.id
output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output firewallPolicyId string = firewallPolicy.id
