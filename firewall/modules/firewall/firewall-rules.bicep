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
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'Net-coll01'
        priority: 120
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Out-DNS'
            ipProtocols: [
              'UDP'
              'TCP'
            ]
            sourceAddresses: [
              '*' // Change to specific source address or CIDR if needed
            ]
            destinationAddresses: [
              '10.112.1.11'
              '10.111.1.11'
            ]
            destinationPorts: [
              '53'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'In-DNS'
            ipProtocols: [
              'UDP'
              'TCP'
            ]
            sourceAddresses: [
              '10.112.1.11'
              '10.111.1.11'
            ]
            destinationAddresses: [
              '*' // Change to specific source address or CIDR if needed
            ]
            destinationPorts: [
              '53'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Out-NYL-Open'
            ipProtocols: [
              'TCP'
              'UDP'
              'ICMP'
              'Any'
            ]
            sourceAddresses: [
              '*' // Change to specific source address or CIDR if needed
            ]
            destinationAddresses: [
              '10.0.0.0/8'
              '172.16.0.0/12'
              '192.168.0.0/16'
            ]
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'In-NYL-Open'
            ipProtocols: [
              'TCP'
              'UDP'
              'ICMP'
              'Any'
            ]
            sourceAddresses: [
              '10.0.0.0/8'
              '172.16.0.0/12'
              '192.168.0.0/16'
            ]
            destinationAddresses: [
              '*' // Change to specific source address or CIDR if needed
            ]
            destinationPorts: [
              '*'
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
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'rc-app-win365-dev-01'
        priority: 120
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'allowMicrosoft'
            sourceAddresses: [
              '*' // Change to specific source address or CIDR if needed
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
              '*' // Change to specific source address or CIDR if needed
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

// // Create NAT Rule Collection Group
// resource natRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
//   parent: firewallPolicy
//   name: 'DefaultDnatRuleCollectionGroup'
//   properties: {
//     priority: 300
//     ruleCollections: [
//       {
//         ruleCollectionType: 'FirewallPolicyNatRuleCollection'
//         name: 'rc-dnat-dev-vdi-01'
//         priority: 150
//         action: {
//           type: 'Dnat'
//         }
//         rules: [
//           {
//             ruleType: 'NatRule'
//             name: 'rc-dnat-dev-vdi-allow'
//             ipProtocols: [
//               'TCP'
//               'UDP'
//               'ICMP'
//               'Any'
//             ]
//             sourceAddresses: [
//               '*'
//             ]
//             destinationAddresses: [
//               '*'
//             ]
//             destinationPorts: [
//               '*'
//             ]
//           }
//         ]
//       }
//     ]
//   }
//   dependsOn: [
//     applicationRuleCollection // Important: rule collection groups must be created sequentially
//   ]
// }

// Output data
output networkRuleCollectionId string = networkRuleCollection.id
output applicationRuleCollectionId string = applicationRuleCollection.id
// output natRuleCollectionId string = natRuleCollection.id
