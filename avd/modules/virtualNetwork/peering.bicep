param vnet1Name string
param vnet1ResourceGroupName string
param vnet2Name string
param vnet2ResourceGroupName string
param allowVirtualNetworkAccess bool = true
param allowForwardedTraffic bool = true
param allowGatewayTransit bool = false
param useRemoteGateways bool = false

resource vnet1PeeringToVnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-06-01' = {
  name: '${vnet1Name}/peering-to-${vnet2Name}'
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: resourceId(vnet2ResourceGroupName, 'Microsoft.Network/virtualNetworks', vnet2Name)
    }
  }
}

resource vnet2PeeringToVnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-06-01' = {
  name: '${vnet2Name}/peering-to-${vnet1Name}'
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: resourceId(vnet1ResourceGroupName, 'Microsoft.Network/virtualNetworks', vnet1Name)
    }
  }
}

output vnet1PeeringName string = vnet1PeeringToVnet2.name
output vnet2PeeringName string = vnet2PeeringToVnet1.name
output vnet1PeeringState string = vnet1PeeringToVnet2.properties.peeringState
output vnet2PeeringState string = vnet2PeeringToVnet1.properties.peeringState
