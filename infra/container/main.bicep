param appName string
param location string
param environment string
param storageAccountName string
param containerRegistryName string
param inputQueueName string
param imageName string
param imageVersion string
param inputStorageContainerName string
param outputStorageContainerName string
param numberOfContainersToCreate int
param keyVaultName string
param storageAccountConnectionStringSecretName string
param logAnalyticsWorkspaceName string
param newBlobCreatedEventGridTopicName string
param storageAccountInputContainerName string
param aciConnectionName string
param eventGridConnectionName string
param orchtestrationFunctionAppName string
param storageAccountOutputContainerName string

var longName = '${appName}-${location}-${environment}'

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

module eventSubscriptionDeployment 'eventSubscription.bicep' = {
  name: 'eventSubscriptionDeployment'
  params: {
    orchtestrationFunctionAppName: orchtestrationFunctionAppName
    storageAccountOutputContainerName: storageAccountOutputContainerName
    newBlobCreatedEventGridTopicName: newBlobCreatedEventGridTopicName
  }
}

module containerInstanceDeployment 'aci.bicep' = {
  name: 'containerInstanceDeployment'
  params: {
    longName: longName
    storageAccountName: storageAccountName
    inputQueueName: inputQueueName
    containerRegistryName: containerRegistryName
    inputStorageContainerName: inputStorageContainerName
    outputStorageContainerName: outputStorageContainerName
    numberOfContainersToCreate: numberOfContainersToCreate
    keyVaultName: keyVaultName
    storageAccountConnectionString: keyVault.getSecret(storageAccountConnectionStringSecretName)
    imageName: imageName
    imageVersion: imageVersion
  }
}

module logicAppDeployment 'logic.bicep' = {
  name: 'logicAppDeployment'
  params: {
    containerInstanceName: containerInstanceDeployment.outputs.containerInstanceName
    longName: longName
    newBlobCreatedEventGridTopicName: newBlobCreatedEventGridTopicName
    storageAccountName: storageAccountName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountInputContainerName: storageAccountInputContainerName
    aciConnectionName: aciConnectionName
    eventGridConnectionName: eventGridConnectionName
  }
}

output containerInstanceName string = containerInstanceDeployment.outputs.containerInstanceName
