<#
.Synopsis
   processApp
.DESCRIPTION
   This script run IntuneWinAppUtil too create Win32 Intune Package
.NOTES
   Disclaimer
   This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
   Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained within the Premier Customer Services Description
#>

param ($SourceFolder,$SourceSetupFile,$OutputFolder,$OutputFileName,$IntuneWinAppUtil,$global:logFile,$openFolder)

Clear-Host
Write-Host "`r`n"
Write-Host "   == GUI Intune Win App Util - Win32 App Intune Convertion ==                Dev SB." -f cyan
Write-Host "`r`n"
Write-Host "   DO NOT Close this Console, you can see Informations about process here"
Write-Host "`r`n"

# ======================== Functions Begin ======================== #
function processApp
{
	writelog "Processing Application..."
	
	Write-Host "Processing Application..." -f cyan
	Start-Sleep -Seconds 2
	Write-Host "`r`n"
	try{
		&$IntuneWinAppUtil -c $SourceFolder -s $SourceSetupFile -o $OutputFolder -q
		$Result = $True
	}
	catch [Exception] {
		$toprint = $_.Exception.Message
		Write-Host "Was not possible Convert Application `r`n$toprint"
		$Result = $False
	}
    checkResult
}

function printDate
{
	$currentDate = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
	return $currentDate
}

function writelog($tolog)
{
    if($global:logFile -eq $null)
	{
		$FileDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
		#$global:logFile = $PSScriptRoot + "\logs\PortalInstall_$FileDate.log"
		$global:logFile = $PSScriptRoot + "\logs\GUIntuneWinAppUtil.log"
	}
	"$(printDate) - $tolog" | Out-File $global:logFile -Append
}

function checkResult
{
	writelog "Checking result..."
	##$tempFile = $OutputFolder+"\"+($SourceSetupFile.split("\")[-1]).split(".")[-2]+".intunewin"
	$tempFile = $OutputFolder+"\"+[System.IO.Path]::GetFileNameWithoutExtension($SourceSetupFile)+".intunewin"
	$finalFile = $OutputFolder+"\"+$OutputFileName
	$extensionFile = $finalFile.Split(".")[-1]
	
	if(!($extensionFile -eq "intunewin"))
	{
		$finalFile = $finalFile+".intunewin"
	}
	
	if(Test-Path $finalFile)
	{
		writelog "$finalFile Already Exist"
		$FileDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
		$nameBack = $finalFile+$FileDate+".bak"
		Rename-Item -Path $finalFile -NewName $nameBack -Force
		writelog "Renaming to $nameBack"
	}
	
	if(Test-Path $tempFile)
	{
		writelog "Created file tempFile: $tempFile"
		writelog "Renaming to $finalFile"
		Rename-Item -Path $tempFile -NewName $finalFile -Force
	}
	
	if(!(Test-Path $finalFile))
	{
		Write-Host "ERROR: The file $finalFile was not Created" -f red
		writelog "ERROR: The file $finalFile was not Created"
	}else
	{
		Write-Host "SUCESS: The file $finalFile was Created" -f cyan
		writelog "SUCESS: The file $finalFile was Created"
		if($openFolder -eq "True"){
			Invoke-Item $OutputFolder
		}
	}
	Write-Host ""
	pause
}

processApp
# ======================== Functions End ======================== #
