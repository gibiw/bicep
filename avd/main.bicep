targetScope = 'subscription'

param resourceGroupName string
param location string
param vnetName string
param addressPrefix string
param subnets array
param hostPoolName string
param workspaceName string
param appGroupName string
param adminUsername string
@secure()
param adminPassword string
param vmCount int = 1

// TODO: create this vnet only for testing. In future, it should be specified in the parameters file
module virtualNetwork 'modules/virtualNetwork/virtualNetwork.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'virtualNetworkDeployment'
  params: {
    vnetName: vnetName
    location: location
    addressPrefix: addressPrefix
    subnets: subnets
  }
}

module hostPool 'modules/hostPool/hostPool.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'hostPoolDeployment'
  params: {
    hostPoolName: hostPoolName
    workspaceName: workspaceName
    appGroupName: appGroupName
    location: location
  }
}

module hostPoolVm 'modules/hostPool/hostPoolVms.bicep' = [
  for i in range(0, length(subnets)): {
    scope: resourceGroup(resourceGroupName)
    name: 'hostPoolVmDeployment-${i}'
    params: {
      vmName: '${hostPoolName}-vm-${i}'
      location: location
      subnetId: virtualNetwork.outputs.subnetIds[0]
      hostPoolId: hostPool.outputs.hostPoolId
      avdRegistrationToken: hostPool.outputs.hostPoolToken
      adminPassword: adminUsername
      adminUsername: adminPassword
      vmCount: vmCount
    }
  }
]
