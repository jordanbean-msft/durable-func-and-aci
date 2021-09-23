param appName string
param location string
param environment string
param storageAccountName string
param managedIdentityName string
param containerRegistryName string
param inputQueueName string
param imageName string
param imageVersion string

var longName = '${appName}-${location}-${environment}'

module containerInstanceDeployment 'aci.bicep' = {
  name: 'containerInstanceDeployment'
  params: {
    longName: longName
    storageAccountName: storageAccountName
    inputQueueName: inputQueueName
    containerRegistryName: containerRegistryName
    managedIdentityName: managedIdentityName
    imageName: imageName
    imageVersion: imageVersion
  }
}

output containerInstanceName string = containerInstanceDeployment.outputs.containerInstanceName
