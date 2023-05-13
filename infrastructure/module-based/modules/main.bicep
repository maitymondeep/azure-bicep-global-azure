targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string
@description('Resource Group Location')
param resourceGroupLocation string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: KvName
  scope: resourceGroup
}

// SQL Parameters
@description('Do you need to Deploy SQL Server')
param deploySQLServer bool
@description('Name of the SQL server')
param sqlServerName string
@description('Username of the SQL Server')
param sqlAdminUserName string
@description('Password of the SQL Server')
param sqlPasswordSecretName string
param KvName string
@description('Name of the SQL Databases, it should be in array format')
param sqlDatabaseNames array

// StorageAccount Parameters
@description('Do you need to Deploy Storage Account')
param deployStorageAccount bool
@minLength(3)
@maxLength(24)
@description('Name of the storage account')
param storageAccountName string

//  AppService Parameters
@description('name of the app service plan')
param appServicePlanName string
@allowed([
  'S1'
  'F1'
])
@description('Define the SKU of the app Service Plan')
param appServicePlanSku string

// WebApp paramters
@description('Name of the app service')
param appServiceName string
@description('Name of appInsights')
param appInsightsNameWebApp string
@minValue(1)
@maxValue(3)
@description('Define the app service plan capacity')
param appServicePlanCapacity int

// CosmosDB Params
@description('Do you need to deploy cosmos DB')
param deployCosmosDB bool
@description('Name of the cosmosDB account name')
param cosmosDBAccountName string
@description('Define the number of cosmosDB account that needs to be created')
param cosmosDBAccountCount int

// SQL Server Module
module sqlServerModule '01_sqlServer.bicep' = {
  name: 'sqlServerModule'
  dependsOn: [ existingKeyVault ]
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
