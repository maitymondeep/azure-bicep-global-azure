param deploySQLServer bool
param sqlServerName string
param sqlAdminUserName string
@secure()
param sqlAdminPassword string
param sqlDatabaseNames array
param location string

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = if(deploySQLServer == 'true') {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUserName
    administratorLoginPassword: sqlAdminPassword
  }
}

//SQL Database
resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = [for name in sqlDatabaseNames: if(deploySQLServer == 'true') {
  parent: sqlServer
  name: name
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}]
