[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification = 'Need plaintext password for .NET API')]
param
(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Production", "Test", "Development")]
    [string]
    $Environment,

    [Parameter(Mandatory=$true)]
    [string]
    $ClientId,

    [Parameter(Mandatory=$true)]
    [string]
    $CertificatePath,

    [Parameter(Mandatory=$true)]
    [string]
    $CertificatePassword,

    [Parameter(Mandatory=$true)]
    [string]
    $EmailAddresses,

    [Parameter(Mandatory=$true)]
    [string]
    $MailboxAddress,

    [Parameter(Mandatory=$true)]
    [string]
    $ApplyLabelEmailSubject,

    [Parameter(Mandatory=$true)]
    [string]
    $ApplyLabelEmailTemplatePath,

    [Parameter(Mandatory=$true)]
    [string]
    $OwnerNotificationEmailSubject,

    [Parameter(Mandatory=$true)]
    [string]
    $OwnerNotificationEmailTemplatePath,

    [Parameter(Mandatory=$true)]
    [string]
    $SensitivityLabelGuid,

    [Parameter(Mandatory=$true)]
    [string]
    $TenantName,

    [Parameter(Mandatory=$true)]
    [string]
    $ProductionDate
)

Import-Module -Name "$PSScriptRoot\resources.psm1" -Force -ErrorAction Stop

# standard 1:1 parameters

    $parameters = @{}
    $parameters.ClientId                      = $ClientId
    $parameters.EmailAddresses                = $EmailAddresses
    $parameters.MailboxAddress                = $MailboxAddress
    $parameters.OwnerNotificationEmailSubject = $OwnerNotificationEmailSubject
    $parameters.ApplylabelEmailSubject        = $ApplyLabelEmailSubject
    $parameters.SensitivityLabelGuid          = $SensitivityLabelGuid
    $parameters.TenantName                    = $TenantName
    $parameters.ProductionDate                = $ProductionDate

# convert certificate to base64 string w/o password

    $parameters.Certificate = Convert-CertificateToBase64String -Path $CertificatePath -Password $CertificatePassword -RemovePasswordProtection

# read in email templates

    $parameters.OwnerNotificationEmailBody = Get-Content -Path $OwnerNotificationEmailTemplatePath -Raw
    $parameters.ApplylabelEmailBody        = Get-Content -Path $ApplyLabelEmailTemplatePath -Raw

New-ParameterFile `
    -OutputPath  "$PSScriptRoot\..\main.parameters.$Environment.json" `
    -Parameters $parameters `
    -Force

