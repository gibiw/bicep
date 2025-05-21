// modules/public-ip.bicep - Module for creating a public IP address

@description('Location for the resource')
param location string

@description('Name of the public IP address')
param publicIpName string

@description('SKU of the public IP address (Basic or Standard)')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Standard'

@description('IP allocation method (Static or Dynamic)')
@allowed([
  'Static'
  'Dynamic'
])
param publicIpAllocationMethod string = 'Static'

@description('IP address version (IPv4 or IPv6)')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIpAddressVersion string = 'IPv4'

@description('Tags for the resource')
param tags object = {}

// Create public IP address
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  tags: tags
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
    publicIPAddressVersion: publicIpAddressVersion
  }
}

// Output data
output publicIpId string = publicIp.id
output publicIpName string = publicIp.name
output publicIpAddress string = publicIp.properties.ipAddress
