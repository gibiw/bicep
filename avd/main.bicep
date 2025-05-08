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

module avdResourceGroup 'modules/resourceGroup/resourceGroup.bicep' = {
  name: 'resourceGroupDeployment'
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

// TODO: create this vnet only for testing. In future, it should be specified in the parameters file
module virtualNetwork 'modules/virtualNetwork/virtualNetwork.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'virtualNetworkDeployment'
  params: {
    vnetName: vnetName
    location: avdResourceGroup.outputs.resourceGroupLocation
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
    location: avdResourceGroup.outputs.resourceGroupLocation
  }
}

module hostPoolVm 'modules/hostPool/hostPoolVms.bicep' = [for i in range(0, length(subnets)): {
  scope: resourceGroup(resourceGroupName)
  name: 'hostPoolVmDeployment-${i}'
  params: {
    vmName: '${hostPoolName}-vm-${i}'
    location: avdResourceGroup.outputs.resourceGroupLocation
    subnetId: virtualNetwork.outputs.subnetIds[i]
    hostPoolId: hostPool.outputs.hostPoolId
    avdRegistrationToken: hostPool.outputs.hostPoolToken
    adminPassword: adminUsername
    adminUsername: adminPassword
    vmCount: vmCount
  }
}]
