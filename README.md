# ap-acitivty-AddUpdateSLMCustomField

## Description
This script is built to be used as an activity in Snow Automation Platform, to add/update custom fields in Snow License Manager.

## Input Parameters
* SLMCustomFieldIdentifierType 
  * Mandatory
  * ValidateSet: CustomFieldId / CustomFieldName / CustomFieldDescription
  * Description: Sets the type of identifier to use in validating the CustomField
* SLMCustomFieldIdentifier
  * Mandatory
  * Description: The identifier value to use in validating the 
* SLMCustomFieldValue
  * Description: Value for the CustomField to add/remove
* SLMCustomFieldElementId
  * Mandatory
  * Description: Id of the object the CustomField belongs to (i.e., ApplicationID, ComputerID, UserID)
* SLMCustomFieldValueUpdatedBy
  * Mandatory
  * Description: String value to record who updated the CustomField

## Settings
* SLMSqlAccountUserName - Username for DB
* SLMSqlServiceAccount - Name of service account
* SLMDatabaseInstance - Connection details for DB Instance
* SLMDatabaseName - DatabaseName (SnowLicenseManager by default)
* SLMCustomerId - The CustomerId in SLM database

## Service Account
One account named by the value of [SLMSqlServiceAccount} with password for the username in [SLMSqlAccountUserName].

## Modules used
* SqlServer
  * Invoke-Sqlcmd

## Before use
Confirm the SLM store procedure used works as written in your SLM instance.

## Repository
This script is maintained in the GitHub Repository found [here](https://github.com/SnowSoftware/ap-acitivty-AddUpdateSLMCustomField).  
Please use GitHub issue tracker if you have any issues with the script. 