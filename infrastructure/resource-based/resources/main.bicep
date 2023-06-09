@description('Location of the RG')
param location string
@description('Name of the app service name')
param appServiceName string
@description('Name of the app Service Plan')
param appServicePlanName string
@description('Name of the app Service Plan SKU')
param appServicePlanSku string
@description('Name of the App Insights')
param appInsightsNameWebApp string
@description('Define the capacity of the app service Plan')
param appServicePlanCapacity int

// App Service plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    capacity: appServicePlanCapacity
  }
}

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
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsightsComponents.properties.InstrumentationKey
      }
    ]
  }
}
