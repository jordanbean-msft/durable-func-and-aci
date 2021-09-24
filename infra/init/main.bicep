param appName string
param location string
param environment string
param adminObjectId string

var longName = '${appName}-${location}-${environment}'
var orchtestrationFunctionAppName = 'func-orchestration-${longName}'

module loggingDeployment 'logging.bicep' = {
  name: 'loggingDeployment'
  params: {
    longName: longName
    orchtestrationFunctionAppName: orchtestrationFunctionAppName
  }
}

module keyVaultDeployment 'keyVault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    adminObjectId: adminObjectId
  }
}

module storageDeployment 'storage.bicep' = {
  name: 'storageDeployment'
  params: {
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
  }
}

module containerRegistryDeployment 'acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
  }
}

module functionDeployment 'func.bicep' = {
  name: 'functionDeployment'
  params: {
    longName: longName
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
    storageAccountInputContainerName: storageDeployment.outputs.inputContainerName
    storageAccountOutputContainerName: storageDeployment.outputs.outputContainerName
    storageAccountConnectionStringSecretName: storageDeployment.outputs.storageAccountConnectionStringSecretName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    orchtestrationFunctionAppName: orchtestrationFunctionAppName
    appInsightsName: loggingDeployment.outputs.appInsightsName
    newBlobCreatedEventGridTopicName: storageDeployment.outputs.newBlobCreatedEventGridTopicName
  }
}

output storageAccountName string = storageDeployment.outputs.storageAccountName
output storageAccountInputContainerName string = storageDeployment.outputs.inputContainerName
output storageAccountInputQueueName string = storageDeployment.outputs.inputQueueName
output storageAccountOutputContainerName string = storageDeployment.outputs.outputContainerName
output containerRegistryName string = containerRegistryDeployment.outputs.containerRegistryName
output keyVaultName string = keyVaultDeployment.outputs.keyVaultName
output logAnalyticsWorkspaceName string = loggingDeployment.outputs.logAnalyticsWorkspaceName
output appInsightsName string = loggingDeployment.outputs.appInsightsName
output newBlobCreatedEventGridTopicName string = storageDeployment.outputs.newBlobCreatedEventGridTopicName
output orchestratorFunctionAppName string = orchtestrationFunctionAppName
output storageAccountConnectionStringSecretName string = storageDeployment.outputs.storageAccountConnectionStringSecretName
