targetScope = 'resourceGroup'

param vnet object
param location string
param resourceGroup_name string

// loop through all the VNet's subnets to see if there are any services to be deployed

// appGW
module appGW 'appGW.bicep' = [for subnet in vnet.subnets: if (contains(subnet, 'serviceAppGW')) {
  name: 'appGW-${subnet.name}'
  scope: resourceGroup(resourceGroup_name)
  params: {
    appGateway_name: subnet.serviceAppGW.name
    appGateway_backendAddressPools_Name: subnet.serviceAppGW.backendAddressPoolsName
    appGateway_VNet_Name: vnet.name
    appGateway_location: location
    appGateway_Subnet_Name: subnet.name
    appGateway_VNet_ResourceGroup: resourceGroup_name
  }
}]

// Azure bastion
module bastion 'bastion.bicep' = [for subnet in vnet.subnets:  if ((contains(subnet, 'serviceBastion')) && (subnet.name == 'AzureBastionSubnet')) {
  name: 'bastion-${subnet.name}'
  scope: resourceGroup(resourceGroup_name)
  params: {
    bastion_name: subnet.serviceBastion.name
    bastion_location: location
    bastion_vnetName: vnet.name
  }
}]
