param longName string
param storageAccountName string
param containerInstanceName string
param newBlobCreatedEventGridTopicName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource aciConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'aci'
  location: resourceGroup().location
  properties: {
     api: {
       id: '/subscriptions/@{encodeURIComponent("${subscription().subscriptionId}")}/providers/Microsoft.Web/locations/@{encodeURIComponent("${resourceGroup().location}")}/managedApis/aci'
     }
     displayName: 'aci'
     parameterValues: {
       
     }
  }
}

resource newBlobCreatedEventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-06-01-preview' = {
  name: '${newBlobCreatedEventGridTopicName}/newBlobCreatedEventSubscription'
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}

resource eventGridConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azureeventgrid'
  location: resourceGroup().location
  properties: {
     api: {
       id: '/subscriptions/@{encodeURIComponent("${subscription().subscriptionId}")}/providers/Microsoft.Web/locations/@{encodeURIComponent("${resourceGroup().location}")}/managedApis/azureeventgrid'
     }
     displayName: 'azureeventgrid'
     parameterValues: {
       
     }
  }
}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-${longName}'
  location: resourceGroup().location
  properties: {    
    definition: {
      parameters: {
      '$connections': {
        defaultValue: {}
        type: 'Object'
      }
      triggers: {
        'When_a_resource_event_occurs': {
          splitOn: '@triggerBody()'
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              properties: {
                destination: {
                  endpointType: 'webhook'
                  properties: {
                    endpointUrl: '@{listCallbackUrl()}'
                  }
                }
                filter: {
                  includedEventTypes: [
                    'Microsoft.Storage.BlobCreated'
                  ]
                }
                topic: storageAccount.id
              }
            }
            host: {
              connection: {
                name: '@parameters("$connections")["azureeventgrid"]["connectionId"]'
              }
            }
            path: '/subscriptions/@{encodeURIComponent("${subscription().subscriptionId}")}/providers/@{encodeURIComponent("Microsoft.Storage.StorageAccounts")}/resource/eventSubscriptions'
            queries: {
              'x-ms-api-version': '2017-06-15-preview'
            }
          }
        }
      }
      actions: {
        'Start_containers_in_a_container_group': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters("$connections")["aci"]["connectionId"]'
              }
            }
            method: 'post'
            path: '/subscriptions/@{encodeURIComponent("${subscription().subscriptionId}")}/resourceGroups/@{encodeURIComponent("${resourceGroup().name}")}/providers/Microsoft.ContainerInstance/containerGroups/@{encodeURIComponent("${containerInstanceName}")}/start'
            queries: {
              'x-ms-api-version': '2019-12-01'
            }
          }
        }
      }
      outputs: {}
    }
    }
    parameters: {
     '$connections': {
       value: {
         aci: {
           connectionId: aciConnection.id
           connectionName: 'aci'
           id: '/subscriptions/@{encodeURIComponent("${subscription().subscriptionId}")}/providers/Microsoft.Web/locations/@{encodeURIComponent("${resourceGroup().location}")}/managedApis/aci'
         }
         azureeventgrid: {
           connectionId: eventGridConnection.id
           connectionName: 'azureeventgrid'
           id: '/subscriptions/@{encodeURIComponent("${subscription().subscriptionId}")}/providers/Microsoft.Web/locations/@{encodeURIComponent("${resourceGroup().location}")}/managedApis/azureeventgrid'
         }
       }
     } 
    }
  }
}
