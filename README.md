# M365 Group Workflows

### Artifacts created by the main.bicep template

<p align="center" width="100%">
    <img src="https://user-images.githubusercontent.com/28455042/191819384-5d92790a-805e-4f2a-9728-188b47308562.png"> 
</p>

### Azure Key Vault Configuration

#### Key Vault Access control (IAM)
An Azure Key Vault will provisioned and secured with RBAC role assignements.  The two Logic Apps in this solution are configured to create a system assigned managed identity (service principal) and will automatically be granted the *Key Vault Secrets Reader* role.  This role allows the two apps read the *clientId* and *certificate* from the keyvault.  You can (optionally) add additional principals to the keyvault to allow future administration. In the example below, I added my dev account to the Key Vault Administrator role during dev and testing.

<p align="center" width="100%">
    <img src="https://user-images.githubusercontent.com/28455042/191824048-798307d6-c313-403e-ac1c-f6a470a54a49.png"> 
</p>

#### Key Vault Network Access
Network access to the Key Vault is also blocked to all public access. The address of the Logic App Connector Outbound IP address list for the EastUS datacenter are automatically added during provisioning.  If the solution is not deployed to the EastUS datacenter the addresses in *main.bicep* must be udpated accordingly. Additionally, if you need to view or managed the secerts from the Azure portal, you will need to add your public IP address to the firewall.

<p align="center" width="100%">
    <img src="https://user-images.githubusercontent.com/28455042/191821452-b48196c3-c1c8-43c2-9bc5-0c856d56ffdc.png"> 
</p>

#### Intial M365 Group Creation Email Notification Workflow 
Logic App Workflow acts as a webhook endpoint which receives an HTTP POST request from SharePoint Online when a GROUP site is created. The Group's GroupId GUID is included in the POST body data. 

<p align="center" width="100%">
    <img src="https://user-images.githubusercontent.com/28455042/191817417-bce8626c-07e2-4b6e-8594-85a1569599dd.png"> 
</p>

#### Public Sensitivity Label Application Workflow
Logic App Workflow acts as a webhook endpoint which receives an HTTP POST request from Power Automate based approval workflow.  When the workflow action is approved it sends the associated GroupId to this workflow which will apply the configured sensitivity label to the M365 Group and email the group owners.

<p align="center" width="100%">
    <img src="https://user-images.githubusercontent.com/28455042/191817459-27a5a9a3-d7ee-4e37-b116-30c5c1891bdb.png"> 
</p>

#### API Connections
The two API connections included in the solution are leveraged by the Logic Apps to access the Azure Key Vault and the Office365 Shared Mailbox.

#### Application Principal Required permissions

<p align="center" width="100%">
    <img src="https://user-images.githubusercontent.com/28455042/193063331-49d9c61c-7a0f-412c-a25b-ff0386c1e62d.png"> 
</p>

