// general/shared parameters
param location       string = 'eastus' // hardecoded eastus datacenter ips below, adjust if you change locations
param clientId       string
param certificate    string
param emailAddresses string
param mailboxAddress string
param productionDate string

// logic_applylabel parameters
param applylabelEmailSubject string
param applylabelEmailBody    string
param tenantName             string
param sensitivityLabelGuid   string

// logic_ownernotification parameters
param ownerNotificationEmailSubject string
param ownerNotificationEmailBody    string

// unique suffix
var suffix = toLower(uniqueString(resourceGroup().id))

// eastus datacenter ipaddresses - https://learn.microsoft.com/en-us/connectors/common/outbound-ip-addresses
var eastus_datacenter = [
    '40.71.249.139'
    '40.71.249.205'
    '40.114.40.132'
    '40.71.11.80/28'
    '40.71.15.160/27'
    '52.188.157.160'
    '20.88.153.176/28'
    '20.88.153.192/27'
    '52.151.221.184'
    '52.151.221.119'
]

module logic_applylabel 'modules/logic-applylabel.bicep' = {
    name: toLower('logic-applylabel-${suffix}')
    scope: resourceGroup()
    params: {
        name: toLower('logic-applylabel-${suffix}')
        location: location
        emailAddresses: emailAddresses
        emailBody: applylabelEmailBody
        emailSubject: applylabelEmailSubject
        mailboxAddress: mailboxAddress
        productionDate: productionDate
        sensitivityLabelGuid: sensitivityLabelGuid
        tenantName: tenantName
        apiConnection_office365: connection_office365.outputs.name
        apiConnection_keyvault: connection_keyvault.outputs.name
    }
    dependsOn: [
        connection_keyvault
        connection_office365
    ]
}

module logic_ownernotification 'modules/logic_ownernotification.bicep' = {
    name: toLower('logic-ownernotification-${suffix}')
    scope: resourceGroup()
    params: {
        name: toLower('logic-ownernotification-${suffix}')
        location: location
        emailAddresses: emailAddresses
        emailBody: ownerNotificationEmailBody
        emailSubject: ownerNotificationEmailSubject
        mailboxAddress: mailboxAddress
        productionDate: productionDate
        apiConnection_office365: connection_office365.outputs.name
        apiConnection_keyvault: connection_keyvault.outputs.name
    }
    dependsOn: [
        connection_keyvault
        connection_office365
    ]
}

module vault 'modules/keyvault.bicep' = {
    name: 'kv-${suffix}'
    scope: resourceGroup()
    params: {
        name: 'kv-${suffix}'
        location: location
        enableRbacAuthorization: true
        networkRuleBypassOptions: 'AzureServices'
        networkRuleDefaultAction: 'Deny'
        ipRules: eastus_datacenter
    }
    dependsOn: [
    ]
}

module vault_secrets 'modules/keyvault-secret.bicep' = {
    name: 'kv-secrets-${suffix}'
    scope: resourceGroup()
    params: {
        keyVault: vault.outputs.name
        secrets: [
            {
                name: 'clientId'
                value: clientId
                contentType: 'text/plain'
            }
            {
                name: 'certificate'
                value: certificate
                contentType: 'application/x-pkcs12'
            }
        ]
    }
    dependsOn: [
        vault
    ]
}

module roles 'modules/roleAssignments.bicep' = {
    name: 'roleAssignments'
    scope: resourceGroup()
    params: {
        roleAssignments: [
            {
                principalId: logic_applylabel.outputs.objectId
                roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User - https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-user
                principalType: 'ServicePrincipal'
            }
            {
                principalId: logic_ownernotification.outputs.objectId
                roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User - https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-user
                principalType: 'ServicePrincipal'
            }
        ]
    }
}

module connection_keyvault 'modules/connection-keyvault.bicep' = {
    name: 'connection-keyvault-${suffix}'
    scope: resourceGroup()
    params: {
        vault: vault.outputs.name
        name: 'connection-keyvault-${suffix}'
        location: location
    }
}

module connection_office365 'modules/connection-office365.bicep' = {
    name: 'connection-office365-${suffix}'
    scope: resourceGroup()
    params: {
        name: 'connection-office365-${suffix}'
        location: location
    }
}
