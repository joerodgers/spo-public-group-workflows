param name string
param location string = resourceGroup().location
param subscriptionId string = subscription().subscriptionId
param gallery string = environment().gallery
param resouceGroup string = resourceGroup().name

resource api_office365 'Microsoft.Web/connections@2016-06-01' = {
  name: name
  location: location
  properties: {
    statuses: [
      {
        status: 'Connected'
      }
    ]
    displayName: name
    api: {
      name: name
      displayName: 'Office 365 Outlook'
      description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organization\'s needs for robust security, reliability, and user productivity.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1538/1.0.1538.2621/office365/icon.png'
      brandColor: '#0078D4'
      id: 'subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        method: 'get'
        requestUri: 'https://${gallery}:443/subscriptions/${subscriptionId}/resourceGroups/${resouceGroup}/providers/Microsoft.Web/connections/${name}/extensions/proxy/testConnection?api-version=2016-06-01'
      }
    ]
  }
}

output name string = api_office365.name
