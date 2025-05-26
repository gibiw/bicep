// modules/network.bicep - Module for creating virtual network with Azure Firewall subnet

@description('Location for the resource')
param location string

@description('Name of the virtual network')
param vnetName string

@description('Address space for virtual network')
param vnetAddressPrefix string

@description('Address prefix for Azure Firewall subnet')
param firewallSubnetPrefix string

@description('Tags for resources')
param tags object = {}

// Important: For Azure Firewall, subnet MUST be named "AzureFirewallSubnet"
var firewallSubnetName = 'AzureFirewallSubnet'

// Create virtual network with Azure Firewall subnet
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: [
        '10.112.1.11'
        '10.111.1.11'
      ]
    }
    subnets: [
      {
        name: firewallSubnetName
        properties: {
          addressPrefix: firewallSubnetPrefix
        }
      }
    ]
  }
}

// Output data
output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
output firewallSubnetId string = virtualNetwork.properties.subnets[0].id
output firewallSubnetName string = firewallSubnetName
