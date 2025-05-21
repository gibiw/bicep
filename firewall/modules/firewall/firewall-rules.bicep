// modules/firewall-rules.bicep - Module for creating Azure Firewall rules

@description('Name of the Azure Firewall')
param firewallName string

// Get the existing Azure Firewall
resource firewall 'Microsoft.Network/azureFirewalls@2021-08-01' existing = {
  name: firewallName
}

// Get the existing Firewall Policy
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' existing = {
  name: '${firewallName}-policy'
}

// Create Network Rule Collection Group
resource networkRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  parent: firewallPolicy
  name: 'networkRuleCollectionGroup'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'allowedNetworkRules'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'allowDNS'
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: [
              '10.0.0.0/16' // Example: your VNet
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '53'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'allowHttp'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.0.0.0/16' // Example: your VNet
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '80'
              '443'
            ]
          }
        ]
      }
    ]
  }
}

// Create Application Rule Collection Group
resource applicationRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  parent: firewallPolicy
  name: 'applicationRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'allowedApplicationRules'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'allowMicrosoft'
            sourceAddresses: [
              '10.0.0.0/16' // Example: your VNet
            ]
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              '*.microsoft.com'
              '*.windowsupdate.com'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'allowAzure'
            sourceAddresses: [
              '10.0.0.0/16' // Example: your VNet
            ]
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              '*.azure.com'
              '*.core.windows.net'
            ]
          }
        ]
      }
    ]
  }
  dependsOn: [
    networkRuleCollection // Important: rule collection groups must be created sequentially
  ]
}

// Create NAT Rule Collection Group
resource natRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  parent: firewallPolicy
  name: 'natRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        name: 'inboundNatRules'
        priority: 300
        action: {
          type: 'Dnat'
        }
        rules: [
          {
            ruleType: 'NatRule'
            name: 'rdpNatRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              firewall.properties.ipConfigurations[0].properties.publicIPAddress.id
            ]
            destinationPorts: [
              '3389'
            ]
            translatedAddress: '10.0.1.4' // Example: internal IP address of server
            translatedPort: '3389'
          }
        ]
      }
    ]
  }
  dependsOn: [
    applicationRuleCollection // Important: rule collection groups must be created sequentially
  ]
}

// Output data
output networkRuleCollectionId string = networkRuleCollection.id
output applicationRuleCollectionId string = applicationRuleCollection.id
output natRuleCollectionId string = natRuleCollection.id
