param appGroupName string
param location string

param hostPoolId string

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-09-09' = {
  name: appGroupName
  location: location
  properties: {
    hostPoolArmPath: hostPoolId
    applicationGroupType: 'Desktop'
    description: 'Desktop Application Group created with Bicep'
    friendlyName: appGroupName
  }
}
