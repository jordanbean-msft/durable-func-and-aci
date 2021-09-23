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

resource blobCreatedEventGridTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: 'NewInputBlobCreated'
  location: resourceGroup().location
  properties: {
    source: storageAccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  } 
}

output storageAccountName string = storageAccount.name
output inputContainerName string = inputContainer.name
output outputContainerName string = outputContainer.name
output inputQueueName string = inputQueue.name
output newBlobCreatedEventGridTopicName string = blobCreatedEventGridTopic.name
