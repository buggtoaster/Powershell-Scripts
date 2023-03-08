# This script will audit all users on a litigation hold and what type of hold they are on.

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
$Mailbox = Get-Mailbox -ResultSize Unlimited
$location = '.\LitigationHolds.csv'

Foreach ($box in $Mailbox){
	$name = $box.Alias
	$hold = ""
	$cases = ""
	$i = 0
	if ($($box.LitigationHoldEnabled) -eq "True"){
		$lhold = "Litigation Hold;"
		$hold = $hold+$lhold
		$i += 1
	}
	if ($($box.InPlaceHolds) -ne $null){
		if ($($box.InPlaceHolds) -match '^UniH.*'){ 
			$ehold = "eDiscovery Hold;"
			$hold = $hold+$ehold
			$i += 1
		}elseif ($($box.InPlaceHolds) -match '^[mbx|skp|grp].*'){
			$rphold = "Purview Retention Policy;"
			$hold = $hold+$rphold
			$i += 1
		}else {
			$iphold = "In-Place Hold;"
			$hold = $hold+$iphold
			$i += 1
		}
	}
	if ($i -ne 0){
		$newline = "{0},{1},{2}" -f $name,$hold,$cases
		$newline | add-content -path $location
	}
}

