param longName string
param managedIdentityName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(replace('sa${longName}', '-', ''))
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource inputQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = {
  name: '${storageAccount.name}/default/input'
}

resource inputContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/input'
}

resource outputContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/output'
}

output storageAccountName string = storageAccount.name
output inputContainerName string = inputContainer.name
output outputContainerName string = outputContainer.name
output inputQueueName string = inputQueue.name
