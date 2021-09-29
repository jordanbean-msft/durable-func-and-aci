param longName string
param keyVaultName string
param storageAccountConnectionStringSecretName string
param storageAccountInputContainerName string
param storageAccountQueueName string
param logAnalyticsWorkspaceName string
param appInsightsName string
param orchtestrationFunctionAppName string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'asp-${longName}'
  location: resourceGroup().location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource orchtestrationFunction 'Microsoft.Web/sites@2021-01-15' = {
  name: orchtestrationFunctionAppName
  location: resourceGroup().location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    reserved: true
    siteConfig: {
      linuxFxVersion: 'Python|3.8'
      pythonVersion: '3.8'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${storageAccountConnectionStringSecretName})'
        }
        {
          name: 'AZURE_STORAGE_CONNECTION_STRING'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${storageAccountConnectionStringSecretName})'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AZURE_STORAGE_INPUT_BLOB_CONTAINER_NAME'
          value: storageAccountInputContainerName
        }
        {
          name: 'AZURE_STORAGE_QUEUE_NAME'
          value: storageAccountQueueName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource functionAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: orchtestrationFunction
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'FunctionAppLogs'
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

resource functionAppKeyVaultGetListSecretAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: orchtestrationFunction.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
        tenantId: orchtestrationFunction.identity.tenantId
      }
    ]
  }
}

output orchtestrationFunctionAppName string = orchtestrationFunctionAppName
