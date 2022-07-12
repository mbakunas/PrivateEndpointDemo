targetScope = 'resourceGroup'

param dns_zoneName string
param dns_recordName string
param dns_endpointNicId string

var ipv4Address = reference(dns_endpointNicId, '2020-01-01').ipConfigurations[0].properties.privateIPAddress

// resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   name: '${dns_zoneName}/${dns_recordName}'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: ''
//       }
//     ]
//   }
// }

output ipAddress string = ipv4Address
