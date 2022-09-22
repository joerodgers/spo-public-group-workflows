param name           string
param vault          string
param location       string = resourceGroup().location
param subscriptionId string = subscription().subscriptionId

resource api_keyvault 'Microsoft.Web/connections@2016-06-01' = {
  name: name
  location: location
  properties: {
    statuses: [
      {
        status: 'Ready'
      }
    ]
    #disable-next-line BCP037
    parameterValueType: 'Alternative'
    #disable-next-line BCP037
    alternativeParameterValues: {
      vaultName: vault
    }
    displayName: name
    api: {
      name: name
      displayName: 'Azure Key Vault'
      description: 'Azure Key Vault is a service to securely store and access secrets.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1596/1.0.1596.2995/keyvault/icon.png'
      brandColor: '#0079d6'
      id: 'subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/keyvault'
      type: 'Microsoft.Web/locations/managedApis'
    }
  }
}

output name string = api_keyvault.name
output id   string = api_keyvault.id


