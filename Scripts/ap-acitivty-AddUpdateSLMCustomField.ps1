## from https://github.com/SnowSoftware/ap-acitivty-AddUpdateSLMCustomField

param(
    
    [Parameter(mandatory = $true)]
    [ValidateSet('CustomFieldId', 'CustomFieldName', 'CustomFieldDescription')]
    [string]
    $SLMCustomFieldIdentifierType,

    [Parameter(mandatory = $true)]
    $SLMCustomFieldIdentifier,

    $SLMCustomFieldValue,

    [Parameter(mandatory = $true)]
    $SLMCustomFieldElementId,

    # [Int32]
    # $SLMCustomFieldCategoryID,

    [Parameter(mandatory = $true)]
    [String]
    $SLMCustomFieldValueUpdatedBy
)


#region debug setup
if ([Environment]::UserInteractive -eq $true -or $APDebugMode) {
    if (-not (Get-Module IgapCore)) {
        try {
            #this part requires that the workflow engine is installed on the machine running this script
            $wfeLocation = (Get-WmiObject win32_service | where-object { $_.Name -eq "Snow Automation Platform Workflow Engine" } | Select-Object PathName).PathName
            $wfeDirectory = $wfeLocation.Substring(1, $wfeLocation.LastIndexOf('\') - 1) 
            $apdirectory = $wfeDirectory.Substring(0, $wfeDirectory.LastIndexOf('\'))
            $apdirectory
            Import-Module "$apdirectory\CoreScripts\IgapCore.psm1"
        }
        catch {
            #if the workflow engine is not installed on the machine running this script, update the path below
            Import-Module 'C:\Program Files\Snow Software\Snow Automation Platform\CoreScripts\IgapCore.psm1'
        }
            
    }
    if (Get-Module IgapCore) {
        if (Test-Path -Path Function:Write-Host) { remove-item -Path Function:Write-Host }
        if (Test-Path -Path Function:Write-Verbose) { remove-item -Path Function:Write-Verbose }
        if (Test-Path -Path Function:Write-Warning) { remove-item -Path Function:Write-Warning }
        if (Test-Path -Path Function:Write-Error) { remove-item -Path Function:Write-Error }
    }
}
#endregion
    
## Confirm module requirements
if (-not (Get-Module SqlServer)) {
    Try {
        Import-Module SqlServer -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to import SqlServer module."
        return
    }
}
    
#region SLM Settings
$SLMSqlAccountUserName = Get-APSetting "SLMSqlAccountUserName"
$SLMSqlServiceAccount = Get-APSetting "SLMSqlServiceAccount"
$SLMDatabaseInstance = Get-APSetting "SLMDatabaseInstance"
$SLMDatabaseName = Get-APSetting "SLMDatabaseName"
$SLMCustomerId = Get-APSetting "SLMCustomerId"
# $SLMSqlServerTrustServerCertificate = Get-APSetting "SLMSqlServerTrustServerCertificate"
$SLMSqlUserAccount = Get-ServiceAccount -Name $SLMSqlServiceAccount

# $securePassword = ConvertTo-SecureString $($SLMSqlUserAccount.Password) -AsPlainText -Force
# $SLMSqlCredentials = New-Object Management.Automation.PSCredential ($SLMSqlAccountUserName, $securePassword)
#endregion


## Validate the CustomFieldIdentifier
switch ($SLMCustomFieldIdentifierType) {
    'CustomFieldId' {
        $queryCustomField = "
            use $SLMDatabaseName
            select CustomFieldID from tblCustomfield where CustomFieldID = $SLMCustomFieldIdentifier
            and CID = $SLMCustomerId
        "
    }
    'CustomFieldName' {
        $queryCustomField = "
            use $SLMDatabaseName
            select CustomFieldID from tblCustomfield where name = '$SLMCustomFieldIdentifier'
            and CID = $SLMCustomerId
        "
    }
    'CustomFieldDescription' {
        $queryCustomField = "
            use $SLMDatabaseName
            select CustomFieldID from tblCustomfield where Description = '$SLMCustomFieldIdentifier'
            and CID = $SLMCustomerId
        "
    }
    default {}

}

$CustomField = Invoke-Sqlcmd -Query $queryCustomField -ServerInstance $SLMDatabaseInstance -Username $SLMSqlAccountUserName -Password $SLMSqlUserAccount.password

## Return if we don't have a unique CustomField id identified
if ($CustomField.CustomFieldID.Count -ne 1) {
    Write-Error "CustomFieldID not uniquely identified."
    return
}


## NOTE: Should add check to confirm ElementID is valid


## try Add/Update the value
$query = "
        use $SLMDatabaseName
        exec CustomFieldValueAddUpdate $SLMCustomFieldIdentifier, $SLMCustomFieldElementId, '$SLMCustomFieldValue', '$SLMCustomFieldValueUpdatedBy'
    "
try {
    $result = Invoke-Sqlcmd -Query $query -ServerInstance $SLMDatabaseInstance -Username $SLMSqlAccountUserName -Password $SLMSqlUserAccount.password -ErrorAction Stop
}
catch {
    Write-Error "Could not Add/Update CustomField. Exception: $_.ErrorMessage"
    return
}

Write-Host "Added/Updated CustomField [$SLMCustomFieldIdentifier], with value [$SLMCustomFieldValue] for element [$SLMCustomFieldElementId] by [$SLMCustomFieldValueUpdatedBy]."