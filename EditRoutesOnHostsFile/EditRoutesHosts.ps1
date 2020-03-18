<#

	This is a SAMPLE Script to Create Routes and Edit Hosts file According with a CSV file.
	You need REVIEW THE .PS1 script File and UNCOMMENT THE 'function AddRoute' line 88 and the '$hostsfilenew' line 139 TO WORKS

	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	WARNING THIS IS A EXAMPLE FILE AND MUST BE FULLY TESTED ON LAB/HOMOLOG ENVIRONMENT BEFORE USE FOR OTHERS PURPOSES.
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	Environment	IPRangeFirst	IPRangeLast		IPdest		IPmask			IPgateway	ServerFQDN							ServerName
	Internet	192.165.0.1		192.168.0.0		10.0.0.1	255.255.255.0	10.0.0.11	SERVERSCCM01.POCMSFT.LOCAL	SERVERSCCM01
	DMZ				11.10.0.1		11.100.0.255	11.0.0.1	255.255.255.0	11.0.0.11	SERVERSCCM02.POCMSFT.LOCAL	SERVERSCCM02

	Author: Sidnei Brandao
	PFE
#>


$global:logFile = $null

$DataCSV = Import-Csv .\data.csv

function printDate{
	$currentDate = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
	return $currentDate
}
function writelog($tolog){
    if ($global:logFile -eq $null)
	{
		$FileDate = Get-Date -Format "yyyy-MM-dd"
		$CurrentFolder = $pwd.Path
		$CurrentFolder.TrimEnd("\")
		$global:logFile = "$($CurrentFolder)\logs\EditRoutesHosts_$FileDate.log" 
	}
	"$(printDate) - $tolog" | Out-File $global:logFile -Append
}

###################################
## CheckRange

function checkIPRange($IPAddress, $FirstIP, $LastIP){
	$iptemp = [system.net.ipaddress]::Parse($IPAddress).GetAddressBytes()
	[array]::Reverse($iptemp)
	$iptemp = [system.BitConverter]::ToUInt32($iptemp, 0)

	$from = [system.net.ipaddress]::Parse($FirstIP).GetAddressBytes()
	[array]::Reverse($from)
	$from = [system.BitConverter]::ToUInt32($from, 0)

	$to = [system.net.ipaddress]::Parse($LastIP).GetAddressBytes()
	[array]::Reverse($to)
	$to = [system.BitConverter]::ToUInt32($to, 0)

	$from -le $iptemp -and $iptemp -le $to
}

$global:RouteSet = $False

$NICIPs = Get-WmiObject Win32_NetworkAdapterConfiguration  | Select -ExpandProperty IPAddress
if (!($NICIPs)){
	writelog "WARNING: IPs not Found, using netsh..."
	$NICIPsTemp = netsh interface ip show address | findstr -i "IP Address"
	$NICIPs = @()
	foreach ($Entry in $NICIPsTemp){
		$NICIPs += $Entry.replace('IP Address:','').replace(' ','')
	}
}
foreach ($IP in $NICIPs){
	if ($IP -notlike '*:*'){
		foreach($Route in $DataCSV){
			$FirstIP = $Route.IPRangeFirst
			$LastIP = $Route.IPRangeLast
			writelog "checking if $IP is between $FirstIP and $LastIP"
			if (checkIPRange $IP $FirstIP $LastIP){
				writelog "Found in Range for $($Route.Environment)"
				$RouteSet = $Route
			}
		}
	}
	if (!($Route)){
		writelog "$IP is Not in Any Range"
	}
}

$IPdest = $($RouteSet.IPdest)
$IPmask = $($RouteSet.IPmask)
$IPgateway = $($RouteSet.IPgateway)
$ServerName = $($RouteSet.ServerName)
$ServerFQDN = $($RouteSet.ServerFQDN)

writelog "Route data: $IPdest $IPmask $IPgateway $ServerName $ServerFQDN"

###################################
## Add Route
if ($RouteSet){
	function AddRoute($addIPdest, $addIPmask, $addIPgateway){
		route delete $IPdest
		if (route add $addIPdest mask $addIPmask $addIPgateway -p){
			$Result = $True
		}else{
			$Result = $False
		}
		Return $Result
	}

	if (AddRoute $IPdest $IPmask $IPgateway){
		Write-Host 'SUCESS: Adding Route' $IPdest -ForeGround cyan
		writelog "SUCESS: Adding Route $IPdest, $IPmask, $IPgateway"
	}else{
		writelog "ERROR: Adding Route $IPdest"
	}

	###################################
	## Edit hosts file

	$hostsfile = @()
	$hostsfile = Get-Content C:\Windows\System32\drivers\etc\hosts
	$hostsfilenew = @()
	$found = $False
	Foreach($line in $hostsfile){
		if ($line -match $IPdest){
			$found = $True
			writelog "WARNING: Found $line in Hosts file Replacing with new Value: $IPdest, $ServerFQDN, $ServerName..."
			$hostsfilenew += $IPdest + '	' + $ServerFQDN + '	' + $ServerName
		}else{
			$hostsfilenew += $line
		}
	}
	if (!($found)){
		writelog "NOT Found Entry in Hosts file Adding new Value: $IPdest, $ServerFQDN, $ServerName..."
		$hostsfilenew += $IPdest + '	' + $ServerFQDN + '	' + $ServerName
	}

	$foundNew = $False
	Foreach($line in $hostsfilenew){
		if ($line -match $IPdest){
			$foundNew = $True
		}
	}

	if ($foundNew){
		writelog "SUCESS: Adding new Value in Hosts File: $IPdest, $ServerFQDN, $ServerName..."
	}else{
		writelog "ERROR: Adding new Value in Hosts File: $IPdest, $ServerFQDN, $ServerName..."
	}

	$hostsfilenew | Out-File C:\Windows\System32\drivers\etc\hosts -Encoding utf8 -Force

	###################################
	## Test Connection

	writelog "Trying to Connect to $ServerName"
	$ResultConnectionServerName = New-Object System.Net.Sockets.TcpClient($ServerName, 80)

	if($ResultConnectionServerName.Connected){
		writelog "SUCESS: Connecting to $ServerName in Port 80"
		writelog "Trying to Connect to $ServerFQDN"
		$ResultConnectionServerFQDN = New-Object System.Net.Sockets.TcpClient($ServerFQDN, 80)
		if($ResultConnectionServerFQDN.Connected){
			writelog "SUCESS: Connecting to $ServerFQDN in Port 80"
		}else{
			writelog "ERROR: Connecting to $ServerFQDN in Port 80"
		}
	}else{
		writelog "ERROR: Connecting to $ServerName in Port 80"
	}
}else{
	writelog "WARNING: No Route condition Found"
}