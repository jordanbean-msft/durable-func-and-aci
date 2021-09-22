param longName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(replace('sa${longName}', '-', ''))
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'BlobStorage'
  properties: {
    accessTier: 'Hot'
  }
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
