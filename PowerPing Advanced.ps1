$serverIP = Read-Host -Prompt '1. Please enter an IP address'
$ipAddresspattern = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

$global:timeDifference = $null

while($serverIP -notmatch $ipAddresspattern) 
{
    clear
	Write-Host "The IP address you entered is incorrect. Please try again."
	$serverIP = Read-Host -Prompt '1. Please enter an IP address'
}

clear
Write-Host "1. Please enter an IP address:"$serverIP

$serverName = Read-Host -Prompt '2. Specify device name and location'
$serverName = $serverName -replace '[^\p{L}\s._0-9\-&^%$#@!)(]+',""

if([string]::IsNullOrEmpty($serverName))
{
	$serverName = "Ping "+$serverIP
}

clear

$logDirectory = [Environment]::GetFolderPath("Desktop") + "\";

If(!(test-path $logDirectory)) 
{
	New-Item -ItemType Directory -Force -Path $logDirectory
}

$logileName = $serverName + ".csv";
$logfileFullPath = $logDirectory + $logileName;

"Date,Time,IP,Description" | Out-File -Append $logfileFullPath -Encoding UTF8

$startTime = (Get-Date).ToString('dd/MM/yyyy | HH:mm:ss')
Set-Variable startCount -option Constant -value (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')

$total = 0
$lost = 0
$transfered = 0

while($true)
{
$total++

    if (Test-Connection $serverIP -Count 1 -Quiet) 
	{ 
		clear
		
		$transfered++

		$startCountDate = [datetime]$startCount
		$timeDifference = NEW-TIMESPAN –Start $startCountDate –End (GET-DATE)
		$timeDifference = “{0:dd} days {0:hh}:{0:mm}:{0:ss}” -f $timeDifference
		
		$header = "Testing: $serverName `nIP address: $serverIP `nStarted at: $startTime | $timeDifference `n"
		Write-Host $header
		
		Write-Host "State: online."
		$lastSeenOnline = (Get-Date).ToString('dd/MM/yyyy | HH:mm:ss')
		
		$result = "(" + [math]::Round($lost*100/$total,2) + "%)"

		
		If ($lastSeenOffline -ne $null)
		{ 
			Write-Host "Lost packets:" $lost"/"$total $result
			Write-Host "Last seen offline:" $lastSeenOffline
		}
		else
		{ 
			Write-Host "Lost packets:" $lost"/"$total $result
			Write-Host "Last seen offline: never." 
		}
	} 
	else 
	{
		(Get-Date).ToString('dd/MM/yyyy,HH:mm:ss') + "," + $serverIP + ",Timed out to " + $serverName | Out-File -Append $logfileFullPath -Encoding UTF8
		clear
		
		$lost++

		$startCountDate = [datetime]$startCount
		$timeDifference = NEW-TIMESPAN –Start $startCountDate –End (GET-DATE)
		$timeDifference = “{0:dd} days {0:hh}:{0:mm}:{0:ss}” -f $timeDifference
		
		$header = "Testing: $serverName `nIP address: $serverIP `nStarted at: $startTime | $timeDifference `n"
		
		Write-Host $header
		
		Write-Host "State: offline." -ForegroundColor Red
		$lastSeenOffline = (Get-Date).ToString('dd/MM/yyyy | HH:mm:ss')
		
		$result = "(" + [math]::Round($lost*100/$total,2) + "%)"
		
		If ($lastSeenOnline -ne $null)
		{ 
			  Write-Host "Lost packets:" $lost"/"$total $result
			  Write-Host "Last seen online:" $lastSeenOnline
		}
		Else
		{ 
			  Write-Host "Lost packets:" $lost"/"$total $result
			  Write-Host "Last seen online: never."
		}
    }
	
Start-Sleep -s 1
}