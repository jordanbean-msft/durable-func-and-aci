param appName string
param location string
param environment string

var longName = '${appName}-${location}-${environment}'

module managedIdentityDeployment 'identity.bicep' = {
  name: 'managedIdentityDeployment'
  params: {
    longName: longName
  }
}

module storageDeployment 'storage.bicep' = {
  name: 'storageDeployment'
  params: {
    longName: longName
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
  }
}

module containerRegistryDeployment 'acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    longName: longName
  }
}

module functionDeployment 'func.bicep' = {
  name: 'functionDeployment'
  params: {
    longName: longName
    storageAccountName: storageDeployment.outputs.storageAccountName
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
  }
}

output storageAccountName string = storageDeployment.outputs.storageAccountName
output storageAccountInputContainerName string = storageDeployment.outputs.inputContainerName
output storageAccountInputQueueName string = storageDeployment.outputs.inputQueueName
output storageAccountOutputContainerName string = storageDeployment.outputs.outputContainerName
output containerRegistryName string = containerRegistryDeployment.outputs.containerRegistryName
output managedIdentityName string = managedIdentityDeployment.outputs.managedIdentityName
