targetScope = 'subscription'

param policyName string
param locationValue string

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Enforce Tag Policy: Environment'
    description: 'This policy enforces the Environment tag on resource groups with specific allowed values.'
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
                field: '[concat(\'tags[\', \'Environment\', \']\')]'
                exists: false
              }
              {
                field: '[concat(\'tags[\', \'Environment\', \']\')]'
                notIn: [
                  'TBD'
                  'Prod'
                  'Model'
                  'Stage'
                  'NonProd'
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
        details: {
          message: 'Resource groups must have an Environment tag with one of the following values: Development, Test, Staging, Production'
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
    displayName: 'Environment Assignment'
    description: 'Enforces the Environment tag on resource groups with specific allowed values.'
    policyDefinitionId: policyDefinition.id
    enforcementMode: 'Default'
  }
}
