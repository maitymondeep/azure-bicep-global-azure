param location string
param appServiceName string
param appServicePlanName string
param appServicePlanSku string
param appInsightsNameWebApp string
param appServicePlanCapacity int
param storageAccountName string
param storageAccountID string

// App Service plan for windows
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    capacity: appServicePlanCapacity
  }
}
output serverFarmID string = appServicePlan.id

// appInsights
resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsNameWebApp
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Web app
resource webApplication 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

// Web app settings
resource appSettings 'Microsoft.Web/sites/config@2022-03-01'= {
  name: 'web'
  parent: webApplication
  properties: {
    appSettings: [
      {
        name: 'Storage_Connection_String'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountID, '2022-09-01').keys[0].value};EndpointSuffix=core.windows.net'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsightsComponents.properties.InstrumentationKey
      }
    ]
  }
}
