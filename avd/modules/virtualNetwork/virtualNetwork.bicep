param vnetName string
param location string
param addressPrefix string
param subnets array = []

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
      }
    }]
  }
}

output name string = vnet.name
output vnetId string = vnet.id
output subnetIds array = [for i in range(0, length(subnets)): vnet.properties.subnets[i].id]
