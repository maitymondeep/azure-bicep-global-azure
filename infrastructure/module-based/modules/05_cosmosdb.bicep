param deployCosmosDB bool
param cosmosDBAccountName string
param cosmosDBAccountCount int
param location string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-11-15' = [for i in range(0, cosmosDBAccountCount): if(deployCosmosDB == 'true') {
  name: '${cosmosDBAccountName}-${i}'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxStalenessPrefix: 1
      maxIntervalInSeconds: 5
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: true
    capabilities: [
      {
        name: 'EnableTable'
      }
    ]
  }
}]
