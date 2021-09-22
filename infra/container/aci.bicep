param longName string

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: 'aci-${longName}'
  properties: {
    containers: [
      
    ]
    osType: 'Linux'
  }
}
