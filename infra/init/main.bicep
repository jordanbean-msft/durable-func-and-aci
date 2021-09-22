param appName string
param location string
param environment string

var longName = '${appName}-${location}-${environment}'

module storageDeployment 'storage.bicep' = {
  name: 'storageDeployment'
  params: {
    longName: longName
  }
}

module containerRegistryDeployment 'acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    longName: longName
  }
}

output storageAccountName string = storageDeployment.outputs.storageAccountName
output storageAccountInputContainerName string = storageDeployment.outputs.inputContainerName
output storageAccountOutputContainerName string = storageDeployment.outputs.outputContainerName
output containerRegistryName string = containerRegistryDeployment.outputs.containerRegistryName
