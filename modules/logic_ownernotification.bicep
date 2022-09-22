param name     string
param location string= resourceGroup().location

param apiConnection_keyvault  string
param apiConnection_office365 string

param mailboxAddress string
param emailBody      string
param emailSubject   string
param emailAddresses string
param productionDate string

var subscriptionId = subscription().subscriptionId
var resouceGroup   = resourceGroup().name

resource logic_ownernotification 'Microsoft.Logic/workflows@2019-05-01' = {
  name: toLower(name)
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              properties: {
                GroupId: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        Determine_Email_Recipients: {
          actions: {
            Condition: {
              actions: {
                'Set_variable_-_Set_Recipients_To_Pilot_Email_Addresses': {
                  runAfter: {
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'EmailToAddresses'
                    value: '@variables(\'DefaultEmailAddresses\')'
                  }
                }
              }
              runAfter: {
              }
              else: {
                actions: {
                  'Set_variable_-_Set_Recipients_to_M365_Group_Owners': {
                    runAfter: {
                    }
                    type: 'SetVariable'
                    inputs: {
                      name: 'EmailToAddresses'
                      value: '@body(\'Join_-_Email_Addresses\')'
                    }
                  }
                }
              }
              expression: {
                and: [
                  {
                    less: [
                      '@variables(\'TodayTicks\')'
                      '@variables(\'PilotExpirationTicks\')'
                    ]
                  }
                ]
              }
              type: 'If'
              description: 'Determine if the pilot is still active'
            }
          }
          runAfter: {
            Lookup_M365_Group_Owners: [
              'Succeeded'
            ]
          }
          type: 'Scope'
        }
        Get_Secrets_from_Azure_Key_Vault: {
          actions: {
            'Get_secret_-_App_Principal_Certificate': {
              runAfter: {
                'Get_secret_-_App_Principal_ClientId': [
                  'Succeeded'
                ]
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'keyvault\'][\'connectionId\']'
                  }
                }
                method: 'get'
                path: '/secrets/@{encodeURIComponent(\'certificate\')}/value'
              }
            }
            'Get_secret_-_App_Principal_ClientId': {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'keyvault\'][\'connectionId\']'
                  }
                }
                method: 'get'
                path: '/secrets/@{encodeURIComponent(\'clientid\')}/value'
              }
            }
          }
          runAfter: {
            'Initialize_variable_-_Pilot_Expiration_Date_in_Ticks': [
              'Succeeded'
            ]
          }
          type: 'Scope'
        }
        'Initialize_variable_-_Default_Email_Addresses': {
          runAfter: {
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'DefaultEmailAddresses'
                type: 'string'
                value: emailAddresses
              }
            ]
          }
        }
        'Initialize_variable_-_Email_Body': {
          runAfter: {
            Lookup_M365_Group_Display_Name: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'EmailBody'
                type: 'string'
                value: emailBody
              }
            ]
          }
        }
        'Initialize_variable_-_Email_Mailbox_Address': {
          runAfter: {
            'Initialize_variable_-_Email_To_Addresses': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'EmailMailboxAddress'
                type: 'string'
                value: mailboxAddress
              }
            ]
          }
        }
        'Initialize_variable_-_Email_Subject': {
          runAfter: {
            'Initialize_variable_-_Default_Email_Addresses': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'EmailSubject'
                type: 'string'
                value: emailSubject
              }
            ]
          }
        }
        'Initialize_variable_-_Email_To_Addresses': {
          runAfter: {
            'Initialize_variable_-_Group_Display_Name': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'EmailToAddresses'
                type: 'string'
                value: '@variables(\'DefaultEmailAddresses\')'
              }
            ]
          }
        }
        'Initialize_variable_-_Group_Display_Name': {
          runAfter: {
            'Initialize_variable_-_Email_Subject': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'GroupDisplayName'
                type: 'string'
              }
            ]
          }
        }
        'Initialize_variable_-_Pilot_Expiration_Date': {
          runAfter: {
            'Initialize_variable_-_Email_Mailbox_Address': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'PilotExpirationDate'
                type: 'string'
                value: productionDate
              }
            ]
          }
        }
        'Initialize_variable_-_Pilot_Expiration_Date_in_Ticks': {
          runAfter: {
            'Initialize_variable_-_Today_in_Ticks': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'PilotExpirationTicks'
                type: 'integer'
                value: '@ticks(formatDateTime(variables(\'PilotExpirationDate\'),\'yyyy-MM-dd\'))'
              }
            ]
          }
        }
        'Initialize_variable_-_Today_in_Ticks': {
          runAfter: {
            'Initialize_variable_-_Pilot_Expiration_Date': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'TodayTicks'
                type: 'integer'
                value: '@ticks(utcNow(\'yyyy-MM-dd\'))'
              }
            ]
          }
        }
        Lookup_M365_Group_Display_Name: {
          actions: {
            'HTTP_-_Invoke_Graph_API_for_M365_Group_DisplayName': {
              runAfter: {
              }
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  clientId: '@body(\'Get_secret_-_App_Principal_ClientId\')?[\'value\']'
                  password: ''
                  pfx: '@body(\'Get_secret_-_App_Principal_Certificate\')?[\'value\']'
                  tenant: subscription().tenantId
                  type: 'ActiveDirectoryOAuth'
                }
                headers: {
                  accept: 'application/json'
                }
                method: 'GET'
                uri: 'https://graph.microsoft.com/v1.0/groups/@{triggerBody()?[\'GroupId\']}?$select=displayname'
              }
            }
            'Parse_JSON_-_Graph_API_Group_Display_Name': {
              runAfter: {
                'HTTP_-_Invoke_Graph_API_for_M365_Group_DisplayName': [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'HTTP_-_Invoke_Graph_API_for_M365_Group_DisplayName\')'
                schema: {
                  properties: {
                    '@@odata.context': {
                      type: 'string'
                    }
                    displayName: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
              }
            }
            'Set_variable_-_Update_GroupDisplayName': {
              runAfter: {
                'Parse_JSON_-_Graph_API_Group_Display_Name': [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'GroupDisplayName'
                value: '@body(\'Parse_JSON_-_Graph_API_Group_Display_Name\')?[\'displayName\']'
              }
            }
          }
          runAfter: {
            Get_Secrets_from_Azure_Key_Vault: [
              'Succeeded'
            ]
          }
          type: 'Scope'
        }
        Lookup_M365_Group_Owners: {
          actions: {
            'HTTP_-_Invoke_Graph_API_for_M365_Group_Owners': {
              runAfter: {
              }
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  clientId: '@body(\'Get_secret_-_App_Principal_ClientId\')?[\'value\']'
                  password: ''
                  pfx: '@body(\'Get_secret_-_App_Principal_Certificate\')?[\'value\']'
                  tenant: subscription().tenantId
                  type: 'ActiveDirectoryOAuth'
                }
                headers: {
                  accept: 'application/json'
                }
                method: 'GET'
                uri: 'https://graph.microsoft.com/v1.0/groups/@{triggerBody()?[\'GroupId\']}/owners?$select=mail'
              }
            }
            'Join_-_Email_Addresses': {
              runAfter: {
                'Select_-_Email_Addresses': [
                  'Succeeded'
                ]
              }
              type: 'Join'
              inputs: {
                from: '@body(\'Select_-_Email_Addresses\')'
                joinWith: '@{join(body(\'Select_-_Email_Addresses\'),\';\')}'
              }
            }
            'Parse_JSON_-_Graph_API_M365_Group_Owner_Response': {
              runAfter: {
                'HTTP_-_Invoke_Graph_API_for_M365_Group_Owners': [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'HTTP_-_Invoke_Graph_API_for_M365_Group_Owners\')'
                schema: {
                  properties: {
                    '@@odata.context': {
                      type: 'string'
                    }
                    value: {
                      items: {
                        properties: {
                          '@@odata.type': {
                            type: 'string'
                          }
                          mail: {
                            type: 'string'
                          }
                        }
                        required: [
                          '@@odata.type'
                          'mail'
                        ]
                        type: 'object'
                      }
                      type: 'array'
                    }
                  }
                  type: 'object'
                }
              }
            }
            'Select_-_Email_Addresses': {
              runAfter: {
                'Parse_JSON_-_Graph_API_M365_Group_Owner_Response': [
                  'Succeeded'
                ]
              }
              type: 'Select'
              inputs: {
                from: '@body(\'Parse_JSON_-_Graph_API_M365_Group_Owner_Response\')?[\'value\']'
                select: '@item()[\'mail\']'
              }
            }
          }
          runAfter: {
            'Initialize_variable_-_Email_Body': [
              'Succeeded'
            ]
          }
          type: 'Scope'
        }
        'Send_an_email_from_a_shared_mailbox_(V2)': {
          runAfter: {
            Determine_Email_Recipients: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              Body: '<p>@{variables(\'EmailBody\')}</p>'
              Importance: 'Normal'
              MailboxAddress: '@variables(\'EmailMailboxAddress\')'
              Subject: '@variables(\'EmailSubject\')'
              To: '@variables(\'EmailToAddresses\')'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v2/SharedMailbox/Mail'
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
      '$connections': {
        value: {
          office365: {
            id: 'subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
            connectionId: '/subscriptions/${subscriptionId}/resourceGroups/${resouceGroup}/providers/Microsoft.Web/connections/${apiConnection_office365}'
            connectionName: apiConnection_office365
          }
          keyvault: {
            id: 'subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/keyvault'
            connectionId: '/subscriptions/${subscriptionId}/resourceGroups/${resouceGroup}/providers/Microsoft.Web/connections/${apiConnection_keyvault}'
            connectionName: apiConnection_keyvault
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
        }
      }
    }
  }
}

output objectId string = logic_ownernotification.identity.principalId
output outgoingConnectorIpAddresses array = logic_ownernotification.properties.endpointsConfiguration.connector.outgoingIpAddresses
