param longName string
param storageAccountName string
param inputQueueName string
param containerRegistryName string
param managedIdentityName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: 'aci-${longName}'
  location: resourceGroup().location
  properties: {
    containers: [
      {
        name: 'compute'
        properties: {
          image: '${containerRegistry.name}.azurecr.io/compute:latest'
          environmentVariables: [
            {
              name: 'AZURE_STORAGE_CONNECTION_STRING'
              secureValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
            }
            {
              name: 'AZURE_STORAGE_QUEUE_NAME'
              value: inputQueueName
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }      
    ]
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

output containerInstanceName string = containerInstance.name
