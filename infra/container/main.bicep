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

var longName = '${appName}-${location}-${environment}'

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
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
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

output containerInstanceName string = containerInstanceDeployment.outputs.containerInstanceName
