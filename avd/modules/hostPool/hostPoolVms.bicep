targetScope = 'resourceGroup'

param vmName string
param vmCount int
param location string
param subnetId string
param hostPoolId string
param avdRegistrationToken string
param adminUsername string
@secure()
param adminPassword string
param vmSize string = 'Standard_D2s_v5'
param osDiskSizeGB int = 128
param imagePublisher string = 'MicrosoftWindowsDesktop'
param imageOffer string = 'windows-11'
param imageSku string = 'win11-22h2-ent'
param imageVersion string = 'latest'

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = [
  for i in range(0, vmCount): {
    name: '${vmName}-${i}-nic'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            subnet: {
              id: subnetId
            }
            privateIPAllocationMethod: 'Dynamic'
          }
        }
      ]
    }
  }
]

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = [
  for i in range(0, vmCount): {
    name: '${vmName}-${i}'
    location: location
    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          diskSizeGB: osDiskSizeGB
        }
        imageReference: {
          publisher: imagePublisher
          offer: imageOffer
          sku: imageSku
          version: imageVersion
        }
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: nic[i].id
          }
        ]
      }
      osProfile: {
        computerName: '${vmName}-${i}'
        adminUsername: adminUsername
        adminPassword: adminPassword
        windowsConfiguration: {
          enableAutomaticUpdates: true
        }
      }
    }
  }
]

resource avdExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [
  for i in range(0, vmCount): {
    name: 'AVDAgent'
    location: location
    parent: vm[i]
    properties: {
      publisher: 'Microsoft.Azure.VirtualDesktop'
      type: 'AVDAgent'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: {
        hostPoolId: hostPoolId
        registrationToken: avdRegistrationToken
      }
    }
  }
]

output vmIds array = [for i in range(0, vmCount): vm[i].id]
