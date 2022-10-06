# Client Prerequisites

## PowerShell Modules

 - PnP.PowerShell
 - Az.Resources
 - Az.Accounts

## Bicep Tools

 - Install Bicep tools - https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install


<br>
<br>
<br>

# Parameter File Generation
To simplify the deployement, this solution leverages Azure Bicep templates for the creation and configuration of resources in Microsoft Azure.  The template requires a number of parameters that are unique to the customer's environemnt.  Customers can use the main.parameters.\<environment>.json  file store static parameter values which are automatically be passed to the deployment job. To generate a parameter file for Development, Test, or Production environments, execute the *.\utils\New-ParameterFile.ps1* file and provide the following parameter values:

Syntax:
```PowerShell
.\New-ParameterFile.ps1 `
    -Environment "<string>" `
    -ClientId "<string>" ` 
    -CertificatePath "<string>"
    -CertificatePassword "<string>"
    -EmailAddresses "<string>"
    -MailboxAddress "<string>"
    -ApplyLabelEmailSubject "<string>"
    -ApplyLabelEmailTemplatePath "<string>"
    -OwnerNotificationEmailSubject "<string>"
    -OwnerNotificationEmailTemplatePath "<string>"
    -SensitivityLabelGuid "<string>"
    -TenantName "<string>"
    -ProductionDate "<string>"
```

Example usage:
```PowerShell
.\New-ParameterFile.ps1 `
    -Environment "Production" `
    -ClientId "74389da2-d93f-408a-b541-1224c7104899" ` 
    -CertificatePath "C:\_temp\pacakges\group-workflow\resources\certificate.pfx"
    -CertificatePassword "password"
    -EmailAddresses "john.doe@contoso.com;jane.doe@contoso.com"
    -MailboxAddress "support@contoso.com"
    -ApplyLabelEmailSubject "Your M365 Group Has Been Updated"
    -ApplyLabelEmailTemplatePath "C:\_temp\pacakges\group-workflow\resources\applylabel-template.html"
    -OwnerNotificationEmailSubject "Your M365 Group Has Been Created"
    -OwnerNotificationEmailTemplatePath "C:\_temp\pacakges\group-workflow\resources\ownernotification-template.html"
    -SensitivityLabelGuid "72d3225d-e45f-4be0-ac15-40e26c422420"
    -TenantName "contoso"
    -ProductionDate "01/01/2023"
```

# Azure Deployment

After installing the necessary Azure Bicep Tools and two Azure PowerShell modules, deploy the bicep template to Azure by excecuting the *deploy-azure.ps1* script.  The script requires several parameters which instructs the deployment to the correct location with the environment specific parameters file (main.parameters.\<environment>.json).   

Syntax:
```PowerShell
.\deploy-azure.ps1 `
    -Environment <string> `
    -TenantId <string> `
    -SubscriptionId <string> `
    -ResourceGroup <string> `
    -Location 'eastus'
```
Example Usage:
```PowerShell
.\deploy-azure.ps1 `
    -Environment 'Production' `
    -TenantId 'b6d59b83-bb12-4878-8297-40301da59cab' `
    -SubscriptionId 'a34d0a44-1fa2-4747-ab93-2f74579b46b4' `
    -ResourceGroup 'rg_groupworkflow_prod_eastus' `
    -Location 'eastus'
```
```
Note: If you deploy to an Azure region other than 'eastus' you will need to first update the Azure Logic Apps IP Address list in the *main.bicep* template file.  These IP address are used expliclty granted access to Azure KeyVault.
```
# SharePoint Online Deployment

After installing the PnP.PowerShell module, deploy the the site design and site script to your Office 365 tenant.  This implementation uses an app-only context to authentication to the SharePoint tenant admin center to deploy the components.  The application principal will need Sites.FullControl.All application permissions.

Syntax:
```PowerShell
.\deploy-spo.ps1 `
    -ClientId  <string> `
    -CertificateThumbprint <string> `
    -WebHookUrl <string> `
    [-Principal <string[]>]
```
Example Usage:
```PowerShell
.\deploy-spo.ps1 `
    -ClientId  'b287cdf8-546b-4114-9cca-6f404272bd4c' `
    -CertificateThumbprint '90a7de419c18da348c17419dba63b42c2198789a' `
    -WebHookUrl 'https://prod-53.eastus.logic.azure.com:443/workflows/...' `
    -Principal 'john.doe@contoso.com','jane.doe@contoso.com','c:0t.c|tenant|338c481e-cabb-4075-bf49-b164c3936c0a'
```
```
Note: The principal 'c:0t.c|tenant|338c481e-cabb-4075-bf49-b164c3936c0a' in the example above contains the ObjectId of an Azure AD security group.  The two otheriuser princiapls are the identifier claim values.
```