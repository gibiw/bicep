targetScope = 'subscription'

param policyName string
param locationValue string

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2024-05-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Inherit Tags Policy'
    description: 'This policy inherits specific tags from the resource group to resources in the subscription if they are missing.'
    metadata: {
      category: 'Tagging'
    }
    policyRule: {
      if: {
        anyOf: [
          { field: '[concat(\'tags[\', \'Cost Center\', \']\')]', exists: false }
          { field: '[concat(\'tags[\', \'Environment\', \']\')]', exists: false }
          { field: '[concat(\'tags[\', \'Severity\', \']\')]', exists: false }
          { field: '[concat(\'tags[\', \'App ID\', \']\')]', exists: false }
          { field: '[concat(\'tags[\', \'Application Name\', \']\')]', exists: false }
          { field: '[concat(\'tags[\', \'App Owner\', \']\')]', exists: false }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
              operation: 'add'
              field: '[concat(\'tags[\', \'Cost Center\', \']\')]'
              value: '[resourceGroup().tags[\'Cost Center\']]'
            }
            {
              operation: 'add'
              field: '[concat(\'tags[\', \'Environment\', \']\')]'
              value: '[resourceGroup().tags[\'Environment\']]'
            }
            {
              operation: 'add'
              field: '[concat(\'tags[\', \'Severity\', \']\')]'
              value: '[resourceGroup().tags[\'Severity\']]'
            }
            {
              operation: 'add'
              field: '[concat(\'tags[\', \'App ID\', \']\')]'
              value: '[resourceGroup().tags[\'App ID\']]'
            }
            {
              operation: 'add'
              field: '[concat(\'tags[\', \'Application Name\', \']\')]'
              value: '[resourceGroup().tags[\'Application Name\']]'
            }
            {
              operation: 'add'
              field: '[concat(\'tags[\', \'App Owner\', \']\')]'
              value: '[resourceGroup().tags[\'App Owner\']]'
            }
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
