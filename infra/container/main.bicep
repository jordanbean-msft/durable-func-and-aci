param appName string
param location string
param environment string
param storageAccountName string
param managedIdentityName string
param containerRegistryName string
param inputQueueName string

var longName = '${appName}-${location}-${environment}'

module containerInstanceDeployment 'aci.bicep' = {
  name: 'containerInstanceDeployment'
  params: {
    longName: longName
    storageAccountName: storageAccountName
    inputQueueName: inputQueueName
    containerRegistryName: containerRegistryName
    managedIdentityName: managedIdentityName
  }
}

output containerInstanceName string = containerInstanceDeployment.outputs.containerInstanceName
