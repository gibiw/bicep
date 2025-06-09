targetScope = 'subscription'

param policyName string
param locationValue string

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Enforce Tag Policy: Severity'
    description: 'This policy enforces the Severity tag on resource groups with specific allowed values.'
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
            anyOf: [
              {
                field: '[concat(\'tags[\', \'Severity\', \']\')]'
                exists: false
              }
              {
                field: '[concat(\'tags[\', \'Severity\', \']\')]'
                notIn: [
                  'Low'
                  'Medium'
                  'High'
                  'Critical'
                ]
              }
            ]
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
    displayName: 'Severity Assignment'
    description: 'Enforces the Severity tag on resource groups with specific allowed values.'
    policyDefinitionId: policyDefinition.id
    enforcementMode: 'Default'
  }
}
