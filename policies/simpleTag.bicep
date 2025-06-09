targetScope = 'subscription'

param policyName string
param tagName string
param locationValue string

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Enforce Tag Policy: ${tagName}'
    description: 'This policy enforces the ${tagName} on resource groups.'
    metadata: {
      category: 'Tagging'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            field: '[concat(\'tags[\', \'${tagName}\', \']\')]'
            exists: false
          }
        ]
      }
      then: {
        effect: 'deny'
        details: {
          message: 'Resource groups must have a ${tagName}'
        }
      }
    }
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2024-05-01' = {
  name: '${policyName}-assignment'
  scope: subscription()
  identity: {
    type: 'SystemAssigned'
  }
  location: locationValue 
  properties: {
    displayName: '${tagName} Assignment'
    description: 'Enforces the ${tagName} on resource groups.'
    policyDefinitionId: policyDefinition.id
    enforcementMode: 'Default'
  }
}
