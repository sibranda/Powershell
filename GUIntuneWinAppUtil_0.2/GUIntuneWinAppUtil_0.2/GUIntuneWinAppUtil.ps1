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
GUI Interface to IntuneWinAppUtil.
.DESCRIPTION
This script will create an Intunewin pack to Intune.
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
   .\Win10_PrimaryUser_Set_Sid.ps1 -DeviceName <DEVICENAME> -UserPrincipalName <UPN@DOMAIN.COM> -SetLicense <YES/NO/TEMP>
    i.e.: .\Win10_PrimaryUser_Set_Sid.ps1 -DeviceName DESKTOP01 -UserPrincipalName sidnei@contoso.com -SetLicense Temp
   
	#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
	#  WARNING THIS IS A EXAMPLE FILE AND MUST BE FULLY TESTED ON LAB/HOMOLOG ENVIRONMENT BEFORE USE FOR OTHERS PURPOSES.  #
	#  You Need to read entire script, understand the code and change according to your needs to adapt to your environment #
	#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
	
	******** To this Script works you NEED to COMMENT the disclaimer line 60

	Author: Sidnei Brandao
	Microsoft Customer Engineer
	Modern IT ܀ Intune ܀ Endpoint ConfigMgr
	
#>


##Set-ExecutionPolicy -ExecutionPolicy Unrestricted -ErrorAction silentlycontinue

function disclaimer{
	cls
	Write-Host "`nTHIS A SAMPLE SCRIPT AND CAN HARM YOUR ENVIRONMENT!!`n`nPlease Read the Disclaimer in the Begining of this Script File BEFORE use!`n" -f red -b black
	Write-Host "Thanks 					`n	SB. `n" -f green
	pause
	exit
}

##disclaimer

$global:logFile = $null

Clear-Host
Write-Host "`r`n"
Write-Host "   == GUI Intune Win App Util - Win32 App Intune Convertion ==                Dev SB. ver 0.2" -f cyan
Write-Host "`r`n"
Write-Host "   DO NOT Close this Console, you can see Informations about process here"
Write-Host "`r`n"

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

# ======================== Use To function Hide-Console Function Begin ======================== #
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
 
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
# ======================== Use To function Hide-Console Function End ======================== #

# ======================== MessagesBoxes Begin ======================== #
function MsgBoxError([string]$text, [string]$titlebar)
{
	$OUTPUT = [System.Windows.Forms.MessageBox]::Show($text , $titlebar , 0, [Windows.Forms.MessageBoxIcon]::Error)
	writeScreen "ERROR: $text"
	writeScreen ""
}

function MsgBoxWarning([string]$text, [string]$titlebar)
{
	$OUTPUT = [System.Windows.Forms.MessageBox]::Show($text , $titlebar , 0, [Windows.Forms.MessageBoxIcon]::Warning)
	writeScreen "WARNING: $text"
	writeScreen ""
}

function MsgBoxOk([string]$text, [string]$titlebar)
{
	$OUTPUT = [System.Windows.Forms.MessageBox]::Show($text , $titlebar , 0, [Windows.Forms.MessageBoxIcon]::Information)
	if ($OUTPUT -eq "OK") 
	{
		writeScreen $text
		writeScreen ""
	} 
}

function MsgBoxContinue([string]$text, [string]$titlebar)
{
    $OUTPUT = [System.Windows.Forms.MessageBox]::Show($text , $titlebar , 4, [Windows.Forms.MessageBoxIcon]::Question)
	if ($OUTPUT -eq "YES") 
	{
		writeScreen $text
		writelog "Selected YES"
		writeScreen ""
		$Result = $true
	}
	else
	{
		$textField.AppendText("`r`n")
		$textField.AppendText($text)
		$textField.AppendText("`r`n")
		$textField.ScrollToCaret()
		writelog $text
		writelog "Selected NO"
		writeScreen ""
		$Result = $False
	}
	Return $Result
}

function MsgBoxOverWrite([string]$text, [string]$titlebar)
{
    $OUTPUT = [System.Windows.Forms.MessageBox]::Show($text , $titlebar , 4, [Windows.Forms.MessageBoxIcon]::Warning)
	if ($OUTPUT -eq "YES") 
	{
		writeScreen "WARNING: $text"
		writelog "Selected YES"
		writeScreen ""
		$Result = $true
	}
	else
	{
		$textField.AppendText("`r`n")
		$textField.AppendText($text)
		$textField.AppendText("`r`n")
		$textField.ScrollToCaret()
		writeScreen "WARNING: $text"
		writelog "Selected NO"
		writeScreen ""
		$Result = $False
	}
	Return $Result
}
# ======================== MessagesBoxes End ======================== #

# ======================== Forms Begin ======================== #
$form = New-Object Windows.Forms.Form
$form.Font = $font
$form.Size = New-Object Drawing.Point 522,406 #less 4 to compile to .exe (orignal 526,400)
#$form.MinimizeBox = $false
$form.MaximizeBox = $false
$form.WindowState = "Normal"    # Maximized, Minimized, Normal
$form.SizeGripStyle = "Hide"    # Auto, Hide, Show
#$form.ShowInTaskbar = $false
$form.FormBorderStyle = 'FixedDialog'  # None or FixedDialog
#$Image = [system.drawing.image]::FromFile($PSScriptRoot + ".\back.jpg")
#$form.BackgroundImage = $Image
#$form.BackColor='#B0C4DE'
$form.BackgroundImageLayout = "Stretch"  # None, Tile, Center, Stretch, Zoom
#form.Opacity = 0.9            # 1.0 is fully opaque; 0.0 is invisible
$form.StartPosition = "WindowsDefaultLocation"  # CenterScreen, Manual, WindowsDefaultLocation, WindowsDefaultBounds, CenterParent
#$iconfile = $PSScriptRoot+"\ico.ico"
#$icon = $iconfile
$icon = $($pwd.path)+"\ico.ico"
$form.Icon = $icon
#Set the dialog title
$form.text = "GUIntuneWinAppUtil 0.2"
$form.KeyPreview = $true
#$form.Add_KeyDown({if ($_.KeyCode -eq "Enter"){$x=$textBox.Text;functioname}})
$form.Add_KeyDown({if ($_.KeyCode -eq "Escape"){$form.Close()}})

# ======================== Labels Begin ======================== #
$labelTitle = New-Object Windows.Forms.Label
$labelTitle.Location = New-Object Drawing.Point 10,10
$labelTitle.Size = New-Object Drawing.Point 450,20
$labelTitle.Text = "==  GUIntuneWinAppUtil - Win32 App Intune Convertion  =="
$labelTitle.Font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Bold)
$labelTitle.ForeColor = "DarkBlue"
$labelTitle.BackColor = "Transparent"

$labelReqInfo = New-Object Windows.Forms.Label
$labelReqInfo.Location = New-Object Drawing.Point 12,40
$labelReqInfo.Size = New-Object Drawing.Point 250,20
$labelReqInfo.Text = "Enter the Required Informations:"
$labelReqInfo.Font = New-Object System.Drawing.Font("Times New Roman",12,[System.Drawing.FontStyle]::Bold)
$labelReqInfo.BackColor = "Transparent"

$labelViewLog = New-Object Windows.Forms.Label
$labelViewLog.Location = New-Object Drawing.Point 10,346
$labelViewLog.Size = New-Object Drawing.Point 61,15
$labelViewLog.Text = "View Log..."
$labelViewLog.Font = New-Object System.Drawing.Font("Times New Roman",8)
$labelViewLog.BackColor = "Transparent"
$labelViewLog.Cursor = 'hand'

$labelDev = New-Object Windows.Forms.Label
$labelDev.Location = New-Object Drawing.Point 467,346
$labelDev.Size = New-Object Drawing.Point 72,15
$labelDev.Text = "Dev SB."
$labelDev.Font = New-Object System.Drawing.Font("Times New Roman",7)
$labelDev.BackColor = "Transparent"
$labelDev.Cursor = 'hand'
# ======================== Labels End ======================== #

# ======================== TextField Begin ======================== #
$textField = New-Object Windows.Forms.RichTextBox
$textField.Location = New-Object Drawing.Point 10,225
$textField.Size = New-Object Drawing.Point 490,120
$textField.font = New-Object System.Drawing.Font("Times New Roman",10)
$textField.BorderStyle = 'none'
$textField.ReadOnly = 'true'
$textField.BackColor = 'White'
$textField.AutoScrollOffset
# ======================== TextField End ======================== #

# ======================== Buttons Begin ======================== #
$buttonHelp = New-Object Windows.Forms.Button
$buttonHelp.Text = "?"
$buttonHelp.Location = New-Object Drawing.Point 480,10
$buttonHelp.Width = "20"

$buttonConvert = New-Object Windows.Forms.Button
$buttonConvert.Text = "Convert"
$buttonConvert.ForeColor = "Blue"
$buttonConvert.Location = New-Object Drawing.Point 350,195
$buttonConvert.Width = "73"

$buttonExit = New-Object Windows.Forms.Button
$buttonExit.Text = "Exit"
$buttonExit.ForeColor = "Red"
$buttonExit.Location = New-Object Drawing.Point 427,195
$buttonExit.Width = "73"
# ======================== Buttons End ======================== #

# ======================== Controls Begin ======================== #
$tooltip = New-Object System.Windows.Forms.ToolTip

$ShowHelp={
	#display popup help
	#each value is the name of a control on the form. 
	Switch ($this.name) {
		"buttonSelectSourceFolder" {$tip = "Select Application Source Folder"}
		"buttonSelectSourceSetupFile" {$tip = "Select Application Source Setup File"}
		"buttonSelectOutputFolder" {$tip = "Select Output Folder to Save intunewin Package"}
		"textBoxSourceFolder"  {$tip = $textBoxSourceFolder.Text}
		"textBoxSourceSetupFile" {$tip = $textBoxSourceSetupFile.Text}
		"textBoxOutputFolder" {$tip = $textBoxOutputFolder.Text}
		"textBoxOutputFileName" {$tip = $textBoxOutputFileName.Text}
		"checkOpenFolder" {$tip = "If Checked, open Output Folder when Convertion Finish"}
	}
	$tooltip.SetToolTip($this,$tip)
}

$labelSourceFolder = New-Object Windows.Forms.Label
$labelSourceFolder.Location = New-Object Drawing.Point 10,82
$labelSourceFolder.Size = New-Object Drawing.Point 108,16
$labelSourceFolder.Text = "Source Folder:"
$labelSourceFolder.Font = New-Object System.Drawing.Font("Times New Roman",9,[System.Drawing.FontStyle]::Regular)

$textBoxSourceFolder = New-Object Windows.Forms.TextBox
$textBoxSourceFolder.Location = New-Object Drawing.Point 119,79
$textBoxSourceFolder.Size = New-Object Drawing.Point 350
$textBoxSourceFolder.Font = New-Object System.Drawing.Font("Times New Roman",10)
$textBoxSourceFolder.Enabled = $False
$textBoxSourceFolder.ReadOnly = $true
$textBoxSourceFolder.Name = "textBoxSourceFolder"
$textBoxSourceFolder.add_MouseHover($ShowHelp)

$buttonSelectSourceFolder = New-Object Windows.Forms.Button
$buttonSelectSourceFolder.Text = "..."
$buttonSelectSourceFolder.Location = New-Object Drawing.Point 470,79
$buttonSelectSourceFolder.Width = "30"
$buttonSelectSourceFolder.Name = "buttonSelectSourceFolder"
$buttonSelectSourceFolder.add_MouseHover($ShowHelp)


$labelSourceSetupFile = New-Object Windows.Forms.Label
$labelSourceSetupFile.Location = New-Object Drawing.Point 10,107
$labelSourceSetupFile.Size = New-Object Drawing.Point 108,16
$labelSourceSetupFile.Text = "Source Setup File:"
$labelSourceSetupFile.Font = New-Object System.Drawing.Font("Times New Roman",9,[System.Drawing.FontStyle]::Regular)

$textBoxSourceSetupFile = New-Object Windows.Forms.TextBox
$textBoxSourceSetupFile.Location = New-Object Drawing.Point 119,104
$textBoxSourceSetupFile.Size = New-Object Drawing.Point 350
$textBoxSourceSetupFile.Font = New-Object System.Drawing.Font("Times New Roman",10)
$textBoxSourceSetupFile.Enabled = $False
$textBoxSourceSetupFile.ReadOnly = $true
$textBoxSourceSetupFile.Name = "textBoxSourceSetupFile"
$textBoxSourceSetupFile.add_MouseHover($ShowHelp)

$buttonSelectSourceSetupFile = New-Object Windows.Forms.Button
$buttonSelectSourceSetupFile.Text = "..."
$buttonSelectSourceSetupFile.Location = New-Object Drawing.Point 470,104
$buttonSelectSourceSetupFile.Width = "30"
$buttonSelectSourceSetupFile.Enabled = $False
$buttonSelectSourceSetupFile.Name = "buttonSelectSourceSetupFile"
$buttonSelectSourceSetupFile.add_MouseHover($ShowHelp)

$labelOutputFolder = New-Object Windows.Forms.Label
$labelOutputFolder.Location = New-Object Drawing.Point 10,132
$labelOutputFolder.Size = New-Object Drawing.Point 108,16
$labelOutputFolder.Text = "Output Folder:"
$labelOutputFolder.Font = New-Object System.Drawing.Font("Times New Roman",9,[System.Drawing.FontStyle]::Regular)

$textBoxOutputFolder = New-Object Windows.Forms.TextBox
$textBoxOutputFolder.Location = New-Object Drawing.Point 119,129
$textBoxOutputFolder.Size = New-Object Drawing.Point 350
$textBoxOutputFolder.Font = New-Object System.Drawing.Font("Times New Roman",10)
$textBoxOutputFolder.Enabled = $False
$textBoxOutputFolder.ReadOnly = $true
$textBoxOutputFolder.Name = "textBoxOutputFolder"
$textBoxOutputFolder.add_MouseHover($ShowHelp)

$buttonSelectOutputFolder = New-Object Windows.Forms.Button
$buttonSelectOutputFolder.Text = "..."
$buttonSelectOutputFolder.Location = New-Object Drawing.Point 470,129
$buttonSelectOutputFolder.Width = "30"
$buttonSelectOutputFolder.Enabled = $False
$buttonSelectOutputFolder.Name = "buttonSelectOutputFolder"
$buttonSelectOutputFolder.add_MouseHover($ShowHelp)

$labelOutputFileName = New-Object Windows.Forms.Label
$labelOutputFileName.Location = New-Object Drawing.Point 10,157
$labelOutputFileName.Size = New-Object Drawing.Point 108,16
$labelOutputFileName.Text = "Output File Name:"
$labelOutputFileName.Font = New-Object System.Drawing.Font("Times New Roman",9,[System.Drawing.FontStyle]::Regular)

$textBoxOutputFileName = New-Object Windows.Forms.TextBox
$textBoxOutputFileName.Location = New-Object Drawing.Point 119,154
$textBoxOutputFileName.Size = New-Object Drawing.Point 350
$textBoxOutputFileName.Font = New-Object System.Drawing.Font("Times New Roman",10)
$textBoxOutputFileName.Enabled = $False
$textBoxOutputFileName.Name = "textBoxOutputFileName"
$textBoxOutputFileName.add_MouseHover($ShowHelp)

$checkOpenFolder = New-Object System.Windows.Forms.CheckBox
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 10
$System_Drawing_Point.Y = 180
$checkOpenFolder.Location = $System_Drawing_Point
$checkOpenFolder.Name = "checkOpenFolder"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 160
$checkOpenFolder.Size = $System_Drawing_Size
$checkOpenFolder.TabIndex = 1
$checkOpenFolder.TabStop = $True
$checkOpenFolder.Text = "Open Folder when Finish"
$checkOpenFolder.UseVisualStyleBackColor = $True
$checkOpenFolder.Name = "checkOpenFolder"
$checkOpenFolder.add_MouseHover($ShowHelp)
# ======================== Controls End ======================== #

$FormEvent_Load={

	#MsgBoxWarning "IN MAINTENNACE! `nScript in maintenance! `nPlease use the old version" "WARNING"
	#exitProgram

	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
	{
	  
	  MsgBoxError "Please be sure to Run as Administrator" "Run as Administrator"
	  $buttonConvert.Enabled = $false
	  exitProgram
	}

	#Hide-Console
	$form.controls.add($labelTitle)
	$form.controls.add($labelReqInfo)
	$form.controls.add($labelViewLog)
	$form.controls.add($labelDev)

	$form.controls.add($buttonHelp)
	$form.controls.add($buttonConvert)
	$form.controls.add($buttonExit)

	$form.controls.add($labelSourceFolder)
	$form.controls.add($textBoxSourceFolder)
	$form.controls.add($buttonSelectSourceFolder)

	$form.controls.add($labelSourceSetupFile)
	$form.controls.add($textBoxSourceSetupFile)
	$form.controls.add($buttonSelectSourceSetupFile)

	$form.controls.add($labelOutputFolder)
	$form.controls.add($textBoxOutputFolder)
	$form.controls.add($buttonSelectOutputFolder)

	$form.controls.add($labelOutputFileName)
	$form.controls.add($textBoxOutputFileName)
	
	$form.controls.add($checkOpenFolder)

	$form.controls.add($textField)
	writeScreen "Welcome to GUIntuneWinAppUtil"
	writeScreen ""
	writeScreen "Convert your Application Win32 to .intunewin Pack"
	writeScreen ""
}

$form.add_Load($FormEvent_Load)
# ======================== Controls End ======================== #

# ======================== Actions Begin ======================== #
$buttonHelp.add_Click({showHelp})
$labelViewLog.add_Click({
	Start-Process $global:logFile
})
$labelDev.add_Click({
	Start-Process "https://www.linkedin.com/in/sidnei-brandao-9925725a/"
})

$buttonSelectSourceFolder.add_Click({selectFolder "Source"})
$buttonSelectSourceSetupFile.add_Click({selectFile})
$buttonSelectOutputFolder.add_Click({selectFolder "Output"})
$buttonConvert.add_Click({
	$buttonConvert.Enabled = $False
	$buttonConvert.Text = "Wait.."
	checkData "Convert"
	$buttonConvert.Enabled = $true
	$buttonConvert.Text = "Convert"
})
$buttonExit.add_Click({exitProgram})
# ======================== Actions End ======================== #

# ======================== Forms End ======================== #

# ======================== Functions Begin ======================== #
function Hide-Console {
	$consolePtr = [Console.Window]::GetConsoleWindow()
	[Console.Window]::ShowWindow($consolePtr, 0)
}

function exitProgram
{
    writelog "Exit Program"
	$form.close()
}

function selectFolder($Option)
{
	$foldername = new-object System.Windows.Forms.folderbrowserdialog
	$foldername.Description = "Select a Folder to Install"
	$foldername.ShowDialog()
	switch -wildcard ($Option)
	{
		"Source"
		{
			$textBoxSourceFolder.Text = $foldername.SelectedPath
			if ($textBoxSourceFolder.Text)
			{
				$toprint = $textBoxSourceFolder.Text
				writelog "Source Folder Selected: $toprint"
				$textBoxSourceFolder.Enabled = $true
				$buttonSelectSourceSetupFile.Enabled = $true
				$textBoxOutputFolder.Text = $env:USERPROFILE+"\Desktop\IntunewinPacks"
				$textBoxOutputFolder.Enabled = $true
				$textBoxOutputFileName.Enabled = $true
				$outputFileName = $textBoxSourceFolder.Text.split("\")[-1]+"_Win32_Pack.intunewin"
				$textBoxOutputFileName.Text = $outputFileName
			}
		}
		"Output"
		{
			if ($foldername.SelectedPath){
				$textBoxOutputFolder.Text = $foldername.SelectedPath
				if ($textBoxOutputFolder.Text)
				{
					$toprint = $textBoxOutputFolder.Text
					writelog "Output Folder Selected: $toprint"
				}
			}
		}

	}
	Remove-Variable Option
}

function selectFile
{
	$loadFileDialog = New-Object System.Windows.Forms.openFileDialog -Property @{
		Filter = 'All Files (*.*)|*.*'
	}
	$loadFileDialog.InitialDirectory = $textBoxSourceFolder.Text	
	$loadFileDialog.Title = "Select the setup file for Application"
	$loadFileDialog.ShowDialog() | Out-Null
	
	if ($loadFileDialog.filename)
	{
		$textBoxSourceSetupFile.Text = $loadFileDialog.filename
		$toprint = $textBoxSourceSetupFile.Text
		writelog "Setup filename: $toprint"
		$textBoxSourceSetupFile.Enabled = $true
		$buttonSelectOutputFolder.Enabled = $true
	}
}

function printDate
{
	$currentDate = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
	return $currentDate
}

function writeScreen ($toScreen,$clear)
{
	if ($clear -eq "Clear")
	{
		$textField.Text = $textField.Text.Clear
	}
	$textField.AppendText($toScreen)
	$textField.AppendText("`r`n")
	$textField.ScrollToCaret()
	writelog $toScreen
}

function writelog($tolog)
{
    if ($global:logFile -eq $null)
	{
		$FileDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
		#$global:logFile = $PSScriptRoot + "\logs\PortalInstall_$FileDate.log"
		$global:logFile = $env:windir + "\Temp\GUIntuneWinAppUtil.log"
	}
	"$(printDate) - $tolog" | Out-File $global:logFile -Append
}

function showHelp
{
	$helpFile = $($pwd.path)+"\help.sid"
	$helpContent = Get-Content -Path $helpFile
	writeScreen "Help Information" "Clear"
	writeScreen ""
    foreach ($line in $helpContent)
	{
		$textField.Appendtext(($line))
		$textField.AppendText("`r`n")
	}
}

function checkData($Option)
{
	$somethingfail = 0
	writeScreen "Starting process..."
	
	$SourceFolder = $textBoxSourceFolder.Text
	if (!($SourceFolder))
	{
		MsgBoxWarning "You need to select a Source Folder Application to Convert" "Select a Source Folder"
		$somethingfail += 1
		return $False
	}
	
	$SourceSetupFile = $textBoxSourceSetupFile.Text
	if (!($SourceSetupFile))
	{
		MsgBoxWarning "You need to select a Setup File for Application to Convert" "Select a Setup File"
		$somethingfail += 1
		return $False
	}
	
	$OutputFolder = $textBoxOutputFolder.Text
	if (!($OutputFolder))
	{
		MsgBoxWarning "You need to select a Output Folder to Application to Convert" "Select a Output Folder"
		$somethingfail += 1
		return $False
	}
	
	$OutputFileName = $textBoxOutputFileName.Text
	if (!($OutputFileName))
	{
		MsgBoxWarning "You need to define a File Name to Application Converted" "Define a File Name"
		$somethingfail += 1
		return $False
	}
	
	if ($somethingfail -eq 0)
	{
		if (MsgBoxContinue "Are you Sure you want to Convert the Application ?" "Confirm to Continue")
		{
			startProcess $Option
		}
	}
}

function checkIntuneWinAppUtil{
	writeScreen "Checking if IntuneWinAppUtil.exe exist..."
	$global:IntuneWinAppUtil = $PSScriptRoot+"\IntuneWinAppUtil.exe"
	if (Test-Path $global:IntuneWinAppUtil)
	{
		writeScreen "IntuneWinAppUtil.exe Found! in $global:IntuneWinAppUtil"
		$Result = $true
	}else
	{
		writeScreen "Error IntuneWinAppUtil NOT Found in $global:IntuneWinAppUtil"
		try
		{
			writeScreen "Trying to Download..."
			$WebClient = New-Object System.Net.WebClient
			$WebClient.DownloadFile("https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe","$PSScriptRoot\IntuneWinAppUtil.exe")
		}
		catch [Exception] {
			$toprint = $_.Exception.Message
			MsgBoxError "Was not possible to Download `r`n$toprint"
			$Result = $False
		}
		
		if (!(Test-Path $global:IntuneWinAppUtil))
		{
			writeScreen "You can manually download from: https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe"
			writeScreen "them copy IntuneWinAppUtil.exe to $PSScriptRoot\ folder and try again"
			$Result = $False
		}else
		{
			writeScreen "IntuneWinAppUtil.exe Downloaded Sucessfully"
			$Result = $true
		}
	}
	return $Result
}

function convertApp
{
	if (checkIntuneWinAppUtil)
	{
		writeScreen "Converting Application, please wait..."
		$SourceFolder = $textBoxSourceFolder.Text
		$SourceSetupFile = $textBoxSourceSetupFile.Text
		$OutputFolder = $textBoxOutputFolder.Text
		$OutputFileName = $textBoxOutputFileName.Text
		
		writelog "Input Data:"
		writelog "SourceFolder $SourceFolder"
		writelog "SourceSetupFile $SourceSetupFile"
		writelog "OutputFolder $OutputFolder"
		writelog "OutputFileName $OutputFileName"
		
		$psfile = $PSScriptRoot+"\processApp.ps1"
		
		#Start-Job -Name $jobName -FilePath $psfile -ArgumentList $textBoxSourceFolder.Text,$textBoxSourceSetupFile.Text,$textBoxOutputFolder.Text,$textBoxOutputFileName.Text,$global:IntuneWinAppUtil
		#$powershellArgs = '-file "' +$psfile+'"' 
		#$powershellArgs = '''-file "' +$psfile+'" "$SourceFolder" "$SourceSetupFile" "$OutputFolder" "$OutputFileName" "$global:IntuneWinAppUtil"'''  
		$openFolder = $checkOpenFolder.Checked
		writeScreen "Open Folder when Finish $openFolder"
		$powershellArgs = '-file "'+$psfile+'" "'+$SourceFolder+'" "'+$SourceSetupFile+'" "'+$OutputFolder+'" "'+$OutputFileName+'" "'+$global:IntuneWinAppUtil+'" "'+$global:logFile+'" "'+$openFolder+'"'
		Start-Process powershell.exe -ArgumentList $powershellArgs
	}
}

function startProcess($Option)
{
	$continue = $true
	#$tempFile = $OutputFolder+"\"+($OutputFileName.split("\")[-1]).split(".")[-2]+".intunewin"
	$extensionFile = $OutputFileName.Split(".")[-1]
	if($extensionFile -eq "intunewin")
	{
		$tempFile = $OutputFolder+"\"+($OutputFileName.split("\")[-1]).split(".")[-2]+".intunewin"
	}
	if(!($extensionFile -eq "intunewin"))
	{
		$tempFile = $OutputFolder+"\"+($OutputFileName.split("\")[-1])+".intunewin"
	}
	writelog "Checking if $tempFile exist..."
	if (Test-Path $tempFile)
	{
		$toprint = $OutputFileName
		if (MsgBoxOverWrite "File $toprint Already Exist, OverWrite?" "OverWrite File?")
		{
			$continue = $true
		}else
		{
			$continue = $false
		}
	}
	if ($continue){
		switch -wildcard ($Option)
		{
			"Convert"
			{
				convertApp
			}
			"Upload"
			{
				#convertApp
				#uploadApp
			}
		}
	}
}

$form.ShowDialog()