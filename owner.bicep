param workflows_logic_ownernotification_xplloo77z5als_name string = 'logic-ownernotification-xplloo77z5als'
param connections_connection_keyvault_xplloo77z5als_externalid string = '/subscriptions/1031813b-fdf3-4576-924a-dfca9603bd29/resourceGroups/rg_deployment_green/providers/Microsoft.Web/connections/connection-keyvault-xplloo77z5als'
param connections_connection_office365_xplloo77z5als_externalid string = '/subscriptions/1031813b-fdf3-4576-924a-dfca9603bd29/resourceGroups/rg_deployment_green/providers/Microsoft.Web/connections/connection-office365-xplloo77z5als'

resource workflows_logic_ownernotification_xplloo77z5als_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_logic_ownernotification_xplloo77z5als_name
  location: 'eastus'
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
                value: 'joe.rodgers@josrod.onmicrosoft.com;adamb@josrod.com'
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
                value: '<!DOCTYPE html>\r\n<html>\r\n<style>\r\n    .notification-table-header {\r\n        width: auto;\r\n        border-top: none;\r\n        background: #ffffff;\r\n        font-size: 11.0pt;\r\n        font-weight: bold;\r\n        font-family: Roboto, Helvetica, sans-serif;\r\n        margin-left: 10px;\r\n        text-align: left;\r\n        border: none;\r\n        border-bottom: solid white 1.5pt;\r\n    }\r\n\r\n    .notification-table-text {\r\n        margin-left: 5px;\r\n        width: 70%;\r\n        text-align: left;\r\n        border: none;\r\n        font-family: Roboto, Helvetica, sans-serif;\r\n        border-bottom: solid white 1.5pt;\r\n        background: #ffffff;\r\n        font-size: 12.0pt;\r\n        height: 20.05pt;\r\n    }\r\n\r\n    .notification-card-footer p {\r\n        vertical-align: baseline;\r\n    }\r\n\r\n    .notification-body {\r\n        margin: 0 auto;\r\n        text-align: center;\r\n        width: 650px;\r\n        border: 1px black;\r\n        border-collapse: collapse;\r\n        background-color: #ffffff;\r\n        font-family: Roboto, Helvetica, sans-serif;\r\n    }\r\n</style>\r\n\r\n<body style="background-color: #ffffff;">\r\n    <table style="width:100%;">\r\n        <tr>\r\n            <td style="padding:0;">\r\n                <div align="center">\r\n                    <table class="notification-body">\r\n                        <tr style="border: 1px grey; border-top:none;">\r\n                            <td>\r\n                                <p style=\'font-size:5.0pt;\'>\r\n                                    <span>&nbsp;</span>\r\n                                </p>\r\n                                <img\r\n                                    src="data:image/png;base64,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" />\r\n                                <table style=\'width:590px;margin:0 auto;border-collapse:collapse;\'>\r\n                                    <tr style=\'height:20.05pt\'>\r\n                                        <td colspan="2" class="notification-table-header"\r\n                                            style=\'width:100%; height:20.05pt\'>\r\n                                            <p style=\'text-align:center; font-size:16.0pt;\'><b>Terms of Service\r\n                                                    Notice</b><br />&nbsp;</p>\r\n                                        </td>\r\n                                    </tr>\r\n                                    <tr>\r\n                                        <td class="notification-table-header">\r\n                                            <span>&nbsp; SharePoint Site:</span>\r\n                                        </td>\r\n                                        <td class="notification-table-text"><strong>Microsoft 365 Group Name:</strong>@{variables(\'GroupDisplayName\')}\r\n                                            </td>\r\n                                    </tr>\r\n                                    <tr class="notification-card-footer">\r\n                                        <td colspan="2">\r\n                                            </br></br>\r\n                                            <p style=\'text-align:left;\'><b>Repsonsibilities</b></p>\r\n                                            <p style=\'text-align:left;\'>Lorem ipsum dolor sit amet, consectetur\r\n                                                adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore\r\n                                                magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco\r\n                                                laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor\r\n                                                in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\r\n                                                pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa\r\n                                                qui officia deserunt mollit anim id est laborum.</p>\r\n                                            <p style=\'text-align:left;\'>Sed ut perspiciatis unde omnis iste natus error\r\n                                                sit voluptatem accusantium doloremque laudantium, totam rem aperiam,\r\n                                                eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae\r\n                                                vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit\r\n                                                aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos\r\n                                                qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui\r\n                                                dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia\r\n                                                non numquam eius modi tempora incidunt ut labore et dolore magnam\r\n                                                aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum\r\n                                                exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea\r\n                                                commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea\r\n                                                voluptate velit esse quam nihil molestiae consequatur, vel illum qui\r\n                                                dolorem eum fugiat quo voluptas nulla pariatur?</p>\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n                    </table>\r\n                </div>\r\n            </td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>'
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
                value: 'sharepointhelp@josrod.onmicrosoft.com'
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
                value: 'M365 Group Creation Notice'
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
                value: '2023-01-01'
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
                  tenant: '1316cd1f-b0c7-4253-a7f3-ccc9041aaaf9'
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
                  tenant: '1316cd1f-b0c7-4253-a7f3-ccc9041aaaf9'
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
          keyvault: {
            connectionId: connections_connection_keyvault_xplloo77z5als_externalid
            connectionName: 'connection-keyvault-xplloo77z5als'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
            id: '/subscriptions/1031813b-fdf3-4576-924a-dfca9603bd29/providers/Microsoft.Web/locations/eastus/managedApis/keyvault'
          }
          office365: {
            connectionId: connections_connection_office365_xplloo77z5als_externalid
            connectionName: 'connection-office365-xplloo77z5als'
            id: '/subscriptions/1031813b-fdf3-4576-924a-dfca9603bd29/providers/Microsoft.Web/locations/eastus/managedApis/office365'
          }
        }
      }
    }
  }
}