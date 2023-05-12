targetScope = 'subscription'
param resourceGroupName string
param resourceGroupLocation string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

// StorageAccount Parameters
param deployStorageAccount bool
@minLength(5)
@maxLength(60)
param storageAccountName string

//  AppService Parameters
param appServicePlanName string
@allowed([
  'S1'
  'F1'
])
param appServicePlanSku string

// WebApp paramters
param appServiceName string
@description('Name of appInsights, Please use the naming convention properly')
param appInsightsNameWebApp string
@minValue(1)
@maxValue(3)
param appServicePlanCapacity int

// CosmosDB Params
param deployCosmosDB bool
param cosmosDBAccountName string
param cosmosDBAccountCount int

// SQL Parameters
param deploySQLServer bool
param sqlServerName string
param sqlAdminUserName string
param sqlPasswordSecretName string
param KvName string
param sqlDatabaseNames array

resource existingKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: KvName
  scope: resourceGroup
}

// SQL Server Module
module sqlServerModule '01_sqlServer.bicep' = {
  name: 'sqlServerModule'
  dependsOn: [existingKeyVault]
  scope: resourceGroup
  params: {
    deploySQLServer: deploySQLServer
    location: resourceGroup.location
    sqlAdminPassword: existingKeyVault.getSecret(sqlPasswordSecretName)
    sqlAdminUserName: sqlAdminUserName
    sqlServerName: sqlServerName
    sqlDatabaseNames: sqlDatabaseNames
  }
}

// Storage Account Module
module storageAccountModule '02_storageAccount.bicep' = {
  name: 'storageAccountModule'
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    deployStorageAccount: deployStorageAccount
    storageAccountName: storageAccountName
    KvName: KvName
  }
}

// AppService Module
module appServiceModule '03_appService.bicep' = {
  name: 'appServiceModule'
  scope: resourceGroup
  params: {
    location: resourceGroup.location
    appInsightsNameWebApp: appInsightsNameWebApp
    appServiceName: appServiceName
    appServicePlanCapacity: appServicePlanCapacity
    appServicePlanName: appServicePlanName
    appServicePlanSku: appServicePlanSku
    storageAccountID: storageAccountModule.outputs.storageAccountID
    storageAccountName: storageAccountModule.name
  }
}

// CosmosDB Module
module cosmosDBModule '05_cosmosdb.bicep' = {
  scope: resourceGroup
  name: 'cosmosDBModule'
  params: {
    cosmosDBAccountCount: cosmosDBAccountCount
    cosmosDBAccountName: cosmosDBAccountName
    deployCosmosDB: deployCosmosDB
    location: resourceGroup.location
  }
}

