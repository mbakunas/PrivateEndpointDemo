targetScope = 'resourceGroup'

param endpoint_location string
param endpoint_resourceName string
param endpoint_resourceResourceId string
param endpoint_groupId array
param endpoint_subnetId string


var endpoint_name = '${endpoint_resourceName}-endpoint'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: endpoint_name
  location: endpoint_location

  properties: {
    subnet: {
      id: endpoint_subnetId
    }
    privateLinkServiceConnections: [
      {
        name: endpoint_name
        properties: {
          privateLinkServiceId: endpoint_resourceResourceId
          groupIds: endpoint_groupId
        }
      }
    ]
    customNetworkInterfaceName: '${endpoint_name}-NIC'
  }
}

output networkInterfaceId string = reference(privateEndpoint.id, '2021-01-01').networkInterfaces[0].id
