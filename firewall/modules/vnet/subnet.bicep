param vnetName string
param subnetName string
param addressPrefix string
param networkSecurityGroupId string = ''
param routeTableId string = ''
param serviceEndpoints array = []
param delegations array = []
param privateEndpointNetworkPolicies string = 'Disabled'
param privateLinkServiceNetworkPolicies string = 'Enabled'

resource existingVnet 'Microsoft.Network/virtualNetworks@2023-06-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  parent: existingVnet
  name: subnetName
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: !empty(networkSecurityGroupId) ? {
      id: networkSecurityGroupId
    } : null
    routeTable: !empty(routeTableId) ? {
      id: routeTableId
    } : null
    serviceEndpoints: serviceEndpoints
    delegations: delegations
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: privateLinkServiceNetworkPolicies
  }
}

output subnetId string = subnet.id
output subnetName string = subnet.name
output subnetAddressPrefix string = subnet.properties.addressPrefix
output subnetResourceId string = subnet.id
