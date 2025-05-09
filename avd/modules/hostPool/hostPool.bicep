@description('Name of the host pool.')
param hostPoolName string

@description('Type of the host pool.')
@allowed([
  'Personal'
  'Pooled'
])
param hostpoolType string = 'Pooled'

@description('Type of load balancer to use for the host pool.')
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param loadBalancerType string = 'BreadthFirst'

@description('Name of the workspace.')
param workspaceName string

@description('Name of the application group.')
param appGroupName string

@description('Location of the resources.')
param location string

param token string = newGuid()

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-11-01-preview' = {
  name: hostPoolName
  location: location
  properties: {
    hostPoolType: hostpoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: 'Desktop'
    registrationInfo: {
      token: token
      registrationTokenOperation: 'Update'
    }
  }
}

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2024-11-01-preview' = {
  name: appGroupName
  location: location
  properties: {
    hostPoolArmPath: hostPool.id
    applicationGroupType: 'Desktop'
  }
}

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2024-11-01-preview' = {
  name: workspaceName
  location: location
  properties: {
    description: 'Workspace for AVD'
    applicationGroupReferences: [
      appGroup.id
    ]
  }
}

output hostPoolId string = hostPool.id
output hostPoolName string = hostPool.name
output hostPoolToken string = hostPool.properties.registrationInfo.token
