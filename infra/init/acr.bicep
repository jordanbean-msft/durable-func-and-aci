param longName string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: replace('aci-${longName}', '-', '')
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
}

output containerRegistryName string = containerRegistry.name
