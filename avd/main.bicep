targetScope = 'subscription'

param resourceGroupName string
param location string
param vnetName string
param addressPrefix string
param subnets array

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
  name: '${uniqueString(deployment().name, location)}-demo'
  params: {
    name: 'hp-demo-001'
    description: 'My first AVD Host Pool'
    friendlyName: 'Demo Host Pool'
    hostPoolType: 'Pooled'
    publicNetworkAccess: 'Enabled'
    loadBalancerType: 'BreadthFirst'
    maxSessionLimit: 99999
    personalDesktopAssignmentType: 'Automatic'
    vmTemplate: {
      customImageId: null
      domain: 'domainname.onmicrosoft.com'
      galleryImageOffer: 'windows-11'
      galleryImagePublisher: 'microsoftwindowsdesktop'
      galleryImageSKU: 'win11-22h2-ent'
      imageType: 'Gallery'
      imageUri: null
      namePrefix: 'avdv2'
      osDiskType: 'StandardSSD_LRS'
      useManagedDisks: true
      vmSize: {
        cores: 2
        id: 'Standard_D2s_v3'
        ram: 8
      }
    }
    agentUpdate: {
      type: 'Scheduled'
      useSessionHostLocalTime: false
      maintenanceWindowTimeZone: 'Alaskan Standard Time'
      maintenanceWindows: [
        {
          hour: 7
          dayOfWeek: 'Friday'
        }
        {
          hour: 8
          dayOfWeek: 'Saturday'
        }
      ]
    }
  }
}

module applicationGroup 'modules/hostPool/applicationGroups.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'applicationGroupDeployment'
  params: {
    appGroupName: 'app-group-demo-001'
    location: location
    hostPoolId: hostPool.outputs.hostPoolId
  }
}

module hostPoolVms 'modules/hostPool/hostPoolVms.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'hostPoolVmsDeployment'
  params: {
    vmName: 'avdvm'
    vmCount: 2
    location: location
    subnetId: virtualNetwork.outputs.subnetIds[0]
    hostPoolName: hostPool.outputs.name
    avdRegistrationToken: hostPool.outputs.token
    adminUsername: 'adminuser'
    adminPassword: 'P@ssw0rd1234!'
    vmSize: 'Standard_D2s_v5'
    osDiskSizeGB: 128
    imagePublisher: 'MicrosoftWindowsDesktop'
    imageOffer: 'windows-11'
    imageSku: 'win11-22h2-ent'
    imageVersion: 'latest'
    domain: 'contoso.com'
    domain_join_username: 'adminuser'
    domain_join_password: 'P@ssw0rd1234!'
  }
}
