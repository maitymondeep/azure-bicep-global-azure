param location string
param storageAccountName string
param deployStorageAccount bool
param KvName string


resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (deployStorageAccount) {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {}
}

// Resource declaration
resource Secret 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: KvName
  resource storageConnectionStringSecret 'secrets' = {
    name: '${storageAccountName}-ConnectionString'
    properties:{
      value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageaccount.id, storageaccount.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'
    }  
  }
}

output storageEndpoint string = deployStorageAccount ? storageaccount.properties.primaryEndpoints.blob : ''
output storageAccountID string = deployStorageAccount ? storageaccount.id : ''
