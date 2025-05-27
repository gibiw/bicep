targetScope = 'subscription'

param policyName string
param locationValue string

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Enforce Tag Policy: Severity'
    description: 'This policy assigns a tag to all resources in the subscription.'
    metadata: {
      category: 'Tagging'
    }
    policyRule: {
      if: {
        allOf:[
          {
            field: 'type'
            equals: 'Microsoft.Rersources/subscriptions/resourceGroups'
          }
          {
            anyOf: [
              {
                field: '[concat(\'tags[\', \'Severity\', \']\')]'
                exists: 'false'
              }
              {
                field: '[concat(\'tags[\', \'Severity\', \']\')]'
                notIn:[
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
  identity:{type:'SystemAssigned'}
  location: locationValue 
  properties: {
    displayName: 'Severity Assignment'
    description: 'Assigns the tagging policy at the subscription level.'
    policyDefinitionId: policyDefinition.id
    enforcementMode: 'Default'
  }
}
