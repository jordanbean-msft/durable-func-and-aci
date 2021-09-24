param longName string
param logAnalyticsWorkspaceName string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: replace('kv${longName}', '-', '')
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard' 
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      
    ]
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource functionAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output keyVaultName string = keyVault.name
