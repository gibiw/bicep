targetScope = 'subscription'

param policyName string
param locationValue string

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Inherit Tags Policy'
    description: 'This policy inherits tags from the resource group to NIC in the subscription.'
    metadata: {
      category: 'Tagging'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'tags'
            exists: true
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            { operation: 'add', field: 'tags', value: '[resourceGroup().tags]' }          
          ]
        }
      }
    }
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: format('{0}-assignment', policyName)
  scope: subscription()
  identity: {
    type: 'SystemAssigned'
  }
  location: locationValue
  properties: {
    displayName: 'Inherit Assignment'
    description: 'Assigns the tagging policy at the subscription level.'
    policyDefinitionId: policyDefinition.id
    enforcementMode: 'Default'
  }
}
