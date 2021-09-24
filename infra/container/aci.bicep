param longName string
param storageAccountName string
param inputQueueName string
param containerRegistryName string
param imageName string
param imageVersion string
param keyVaultName string
param inputStorageContainerName string
param outputStorageContainerName string
@secure()
param storageAccountConnectionString string
param numberOfContainersToCreate int
param logAnalyticsWorkspaceName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: 'aci-${longName}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    containers: [for i in range(0, numberOfContainersToCreate): {
        name: '${imageName}${i}'
        properties: {
          image: '${containerRegistry.name}.azurecr.io/${imageName}:${imageVersion}'
          environmentVariables: [
            {
              name: 'AZURE_STORAGE_CONNECTION_STRING'
              secureValue: storageAccountConnectionString
            }
            {
              name: 'AZURE_STORAGE_QUEUE_NAME'
              value: inputQueueName
            }
            {
              name: 'AZURE_STORAGE_INPUT_BLOB_CONTAINER_NAME'
              value: inputStorageContainerName
            }
            {
              name: 'AZURE_STORAGE_OUTPUT_BLOB_CONTAINER_NAME'
              value: outputStorageContainerName
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }]
    osType: 'Linux'
    restartPolicy: 'Never'
    imageRegistryCredentials: [
      {
        server: '${containerRegistry.name}.azurecr.io'
        username: listCredentials(containerRegistry.id, containerRegistry.apiVersion).username
        password: listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords[0].value
      }
    ]
  }
}

resource functionAppKeyVaultGetListSecretAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: containerInstance.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
        tenantId: containerInstance.identity.tenantId
      }
    ]
  }
}

output containerInstanceName string = containerInstance.name
