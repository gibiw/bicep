targetScope = 'subscription'

param policyName string
param locationValue string

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Enforce Tag Policy: Cost Center'
    description: 'This policy enforces the Cost Center tag on resource groups.'
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
            field: '[concat(\'tags[\', \'Cost Center\', \']\')]'
            exists: false
          }
        ]
      }
      then: {
        effect: 'deny'
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
    displayName: 'Cost Center Assignment'
    description: 'Enforces the Cost Center tag on resource groups.'
    policyDefinitionId: policyDefinition.id
    enforcementMode: 'Default'
  }
}
