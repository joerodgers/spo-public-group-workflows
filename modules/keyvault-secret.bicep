@description('Parent vault name')
param keyVault string

#disable-next-line secure-secrets-in-params
param secrets array = []

resource vault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVault
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = [for (secret, index) in secrets: {
  name:  secret.name
  parent: vault
  properties: {
    value: secret.value
    contentType: secret.contentType
  }
}]

