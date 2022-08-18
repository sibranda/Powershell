#This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
#THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
#EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
#provided that You agree: 
#(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
#(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and 
#(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys' fees,
#that arise or result from the use or distribution of the Sample Code.
#Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained within the Premier Customer Services Description


##############################################################################################
<#
.Synopsis
Convert Azure AD Group ID to SID
.DESCRIPTION
This script will Converts an Azure AD Object User or Group ID to SID.
The script allow you to connect to your Azure Tenant and Search User or Group by Name.
.URL
https://github.com/sibranda/Powershell/tree/master/Convert-AzureAdUserorGroupIdToSid
.NOTES
   Disclaimer
   This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
   THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
   INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
   We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
   provided that You agree:
	(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
	(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and 
	(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits,
		including attorneys™ fees, that arise or result from the use or distribution of the Sample Code.
   Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained within the 
   Premier Customer Services Description
.EXAMPLE COMMAND LINE
   .\Convert-Convert-AzureAdUserorGroupIdToSid.ps1
    i.e.: .\Convert-Convert-AzureAdUserorGroupIdToSid.ps1
   
	#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
	#  WARNING THIS IS A EXAMPLE FILE AND MUST BE FULLY TESTED ON LAB/HOMOLOG ENVIRONMENT BEFORE USE FOR OTHERS PURPOSES.  #
	#  You Need to read entire script, understand the code and change according to your needs to adapt to your environment #
	#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
	
	******** To this Script works you NEED to COMMENT the disclaimer line 60

	Author: Sidnei Brandao
	Microsoft Customer Engineer
	Modern IT ܀ Intune ܀ Endpoint ConfigMgr
	
#>
cls
Write-Host "Welcome to Convert Azure AD User or Group ID to SID"
Write-Host "This Script will help you to convert your Azure AD User or Group ID to SID"
Write-Host "Just type the Azure AD User Name, or Group Name or string to search and hit ENTER"
Write-Host "                                                                Dev. SidSB"

Write-Host "Checking for AzureAD module..."

$azModule = Get-Module -Name "AzureAD" -ListAvailable

if ($azModule -eq $null) {
	write-host
	write-host "AzureAD Powershell module not installed..." -f r
	write-host "Install by running 'Install-Module AzureAD'" -f y
	write-host "Script can't continue..." -f r
	write-host
	pause
	exit
}

if (!($AzAD)) {$AzAD = Connect-AzureAD -ErrorAction SilentlyContinue}

if ($AzAD){

	function Convert-AzureAdObjectIdToSid {
		param([String]$AzureADObject)


		$AZGroup = Get-AzureADGroup -SearchString $AzureADObject
		$AZUser = Get-AzureADUser -SearchString $AzureADObject
		$numberazg = 0
		if ($AZGroup){
			$numazobject = $AZGroup.count
			Write-Host "Azure AD Groups Found: $numazobject" -f yellow
			While ($numberazg -lt $AZGroup.count){
				[String] $ObjectId = ($AZGroup[$numberazg] | Select ObjectId).ObjectId
				
				$tempID = [Guid]::Parse($ObjectId).ToByteArray()
				$arraySID = New-Object 'UInt32[]' 4

				[Buffer]::BlockCopy($tempID, 0, $arraySID, 0, 16)
				$AZGroupSid = "S-1-12-1-$arraySID".Replace(' ', '-')
				
				
				
				Write-Host ""
				Write-Host "Azure AD Group: "  -f y ($AZGroup[$numberazg] | Select DisplayName).DisplayName
				Write-Host "Azure AD Object ID: " $ObjectId
				Write-Host "Azure AD SID: " $AZGroupSid -f c
				$numberazg ++
			}
		}
		
		if($AZUser){
			$numazobject = $AZUser.count
			Write-Host "Azure AD Users Found: $numazobject" -f Green
			While ($numberazg -lt $AZUser.count){
				[String] $ObjectId = ($AZUser[$numberazg] | Select ObjectId).ObjectId
				
				$tempID = [Guid]::Parse($ObjectId).ToByteArray()
				$arraySID = New-Object 'UInt32[]' 4

				[Buffer]::BlockCopy($tempID, 0, $arraySID, 0, 16)
				$AZGroupSid = "S-1-12-1-$arraySID".Replace(' ', '-')
				
				
				
				Write-Host ""
				Write-Host "Azure AD User: "  -f Green ($AZUser[$numberazg] | Select DisplayName).DisplayName
				Write-Host "UPN: " -f Green ($AZUser[$numberazg] | Select UserPrincipalName).UserPrincipalName 
				Write-Host "Azure AD Object ID: " $ObjectId
				Write-Host "Azure AD SID: " $AZGroupSid -f c
				$numberazg ++
			}
		}
	}
	While ($True){
		Write-Host ""
		$AzureGroupSearch = Read-Host -Prompt 'Input Azure AD Group Name or Azure AD User Name'
		Convert-AzureAdObjectIdToSid -AzureADObject $AzureGroupSearch
		Write-Host ""
	}
}else{
	Write-Host "You Need to Connect to Azure AD" -f r
} 
