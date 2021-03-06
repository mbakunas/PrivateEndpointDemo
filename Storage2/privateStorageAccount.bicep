targetScope = 'resourceGroup'

param location string

param storageAccount_name string
param storageAccount_kind string
param storageAccount_skuName string
param storageAccount_accessTier string
param storageAccount_supportsHttpsTrafficOnly bool
param storageAccount_publicNetworkAccess string
param storageAccount_allowBlobPublicAccess bool
param storageAccount_allowSharedKeyAccess bool
param storageAccount_defaultOAuth bool
param storageAccount_isHnsEnabled bool
param storageAccount_keySource string
param storageAccount_infrastructureEncryptionEnabled bool
param endpoint_vnetName string
param endpoint_subnetName string
param endpoint_vnetRg string
param dns_zoneRG string

var storageAccount_minimumTlsVersion = 'TLS1_2'
var storageAccount_encryptionEnabled = true
var endpoint_name = '${storageAccount_name}-endpoint'
var endpoint_subnetId = resourceId(endpoint_vnetRg, 'Microsoft.Network/virtualNetworks/subnets', endpoint_vnetName, endpoint_subnetName)
var endpoint_serviceNames = {
  blob: {
    connectionName: '${endpoint_name}-blob-${uniqueString(endpoint_name)}'
    privateDnsZoneName: 'privatelink.blob.${environment().suffixes.storage}'
    groupIds: [
      'blob'
    ]
  }
  file: {
    connectionName: '${endpoint_name}-file-${uniqueString(endpoint_name)}'
    privateDnsZoneName: 'privatelink.file.${environment().suffixes.storage}'
    groupIds: [
      'file'
    ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccount_name
  location: location

  kind: storageAccount_kind
  sku: {
    name: storageAccount_skuName
  }
  properties: {
    accessTier: storageAccount_accessTier
    minimumTlsVersion: storageAccount_minimumTlsVersion
    supportsHttpsTrafficOnly: storageAccount_supportsHttpsTrafficOnly
    publicNetworkAccess: storageAccount_publicNetworkAccess
    allowBlobPublicAccess: storageAccount_allowBlobPublicAccess
    allowSharedKeyAccess: storageAccount_allowSharedKeyAccess
    defaultToOAuthAuthentication: storageAccount_defaultOAuth
    isHnsEnabled: storageAccount_isHnsEnabled
    encryption: {
      keySource: storageAccount_keySource
      services: {
        blob: {
          enabled: storageAccount_encryptionEnabled
          keyType: 'Account'
        }
        file: {
          enabled: storageAccount_encryptionEnabled
          keyType: 'Account'
        }
        table: {
          enabled: storageAccount_encryptionEnabled
          keyType: 'Account'
        }
        queue: {
          enabled: storageAccount_encryptionEnabled
          keyType: 'Account'
        }
      }
      requireInfrastructureEncryption: storageAccount_infrastructureEncryptionEnabled
    }
  }
}

module privateEndpoint 'Modules/PrivateEndpoint.bicep' = {
  name: '${deployment().name}-privateEndpoint'
  params: {
    endpoint_location: location
    endpoint_resourceResourceId: storage.id
    endpoint_resourceName: storageAccount_name
    endpoint_subnetId: endpoint_subnetId
    endpoint_groupId: endpoint_serviceNames.file.groupIds
  }
}

module dnsArecord 'Modules/Arecord.bicep' = {
  name: '${deployment().name}-dnsArecord'
  scope: resourceGroup(dns_zoneRG)
  params: {
    dns_endpointNicId: privateEndpoint.outputs.networkInterfaceId
    dns_recordName: storageAccount_name
    dns_zoneName: endpoint_serviceNames.file.privateDnsZoneName
  }
}
