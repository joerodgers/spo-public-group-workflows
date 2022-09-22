param vault string
param identity string
param addresses array
param location string = resourceGroup().location
param forceUpdateTag string = newGuid()

resource script_cli 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-kvipaddresslist'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}': {}
    }
  }
  properties: {
    azCliVersion: '2.39.0'
    forceUpdateTag: forceUpdateTag
    cleanupPreference: 'Always'
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    environmentVariables: [
      {
        name: 'vault'
        value: vault
      }
      {
        name: 'resourcegroup'
        value: resourceGroup().name
      }
      {
        name: 'ipaddresses'
        value: string(addresses)
      }
    ]
    scriptContent: ''' 

      # expected ipaddresses format: ["40.71.249.139","40.71.249.205","40.114.40.132","40.71.11.80/28","40.71.15.160/27","52.188.157.160","20.88.153.176/28","20.88.153.192/27","52.151.221.184","52.151.221.119"]

      IFS=','

      addresses=$ipaddresses

      f="["; r=""
      addresses=${addresses//$f/$r}
      
      f="]"; r=""
      addresses=${addresses//$f/$r}
      
      f='"'; r=""
      addresses=${addresses//$f/$r}
      
      # split string into array
      read -ra ips <<< "$addresses"

      # add new ip address list
      for ip in $addresses
      do
        az keyvault network-rule add --name $vault --resource-group $resourcegroup --ip-address $ip
      done
    '''
  }
}
