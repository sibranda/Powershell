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
This script will convert an Azure AD Group ID to SID.
.URL
https://github.com/sibranda/Powershell/tree/master/Convert-AzureAdGroupIdToSid
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
   .\Convert-AzureAdGroupIdToSid.ps1
    i.e.: .\Convert-AzureAdGroupIdToSid.ps1
   
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
Write-Host "Welcome to Convert Azure AD Group ID to SID"
Write-Host "This Script will help you to convert your Azure AD Group ID to SID"
Write-Host "Just type the Azure AD Group Name or string to search and hit ENTER"
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
		param([String]$AzureADGroupName)


		$AZGroup = Get-AzureADGroup -SearchString $AzureADGroupName
		$numberazg = 0
		While ($numberazg -lt $AZGroup.count){
			[String] $ObjectId = ($AZGroup[$numberazg] | Select ObjectId).ObjectId
			
			$tempID = [Guid]::Parse($ObjectId).ToByteArray()
			$arraySID = New-Object 'UInt32[]' 4

			[Buffer]::BlockCopy($tempID, 0, $arraySID, 0, 16)
			$AZGroupSid = "S-1-12-1-$arraySID".Replace(' ', '-')
			
			
			
			Write-Host ""
			Write-Host "Azure AD Group: " ($AZGroup[$numberazg] | Select DisplayName).DisplayName
			Write-Host "Azure AD Object ID: " $ObjectId -f y
			Write-Host "Azure AD SID: " $AZGroupSid -f c
			$numberazg ++
		}
	}
	While ($True){
		Write-Host ""
		$AzureGroupSearch = Read-Host -Prompt 'Input Azure AD Group Name'
		Convert-AzureAdObjectIdToSid -AzureADGroupName $AzureGroupSearch
		Write-Host ""
	}
}else{
	Write-Host "You Need to Connect to Azure AD" -f r
} 
