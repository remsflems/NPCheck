#declaration
function Format-Result([String] $srcstr) {
	$a = $srcstr.toCharArray()
	$r =""
	foreach ($l in $a) {
		$c = [int][char]$l
		if (-Not ($c -eq 13 -Or $c -eq 10 -Or $c -eq 0)) {
			if ($c -eq 218 -Or $c -eq 222) {
				$v="e"
				$r = "$r$v"
			} ElseIf ($c -eq 189 -Or $c -eq 225) {
				$r = "$r"
			} else {
				$r = "$r$l"
			}
		}
	}
	$r = $r -replace '\W', ' '
	return $r
}


#Start process verification
$prolist = Get-CimInstance Win32_Process | Sort-Object -Property ProcessId
$nettcp = Get-NetTCPConnection |Select-Object -Property OwningProcess,LocalAddress,LocalPort,RemoteAddress,RemotePort
$netudp = Get-NetUDPEndpoint |Select-Object -Property OwningProcess,LocalAddress,LocalPort,RemoteAddress,RemotePort

#$idlist = Get-CimInstance Win32_Process |Select-Object -Property ProcessId,Name
#initialize corrupted DLL list
$ListCheckedDll = @()
$ListBadDll = @()
$ListGoodDll = @()
$ListUnknownDll = @()
$logfile = "NPChek-$env:computername-$(get-date -f yyyy-MM-dd)-report.log"
$output = ""
Write-Host "----> Welcome to NPcheck."
Write-Host "----> NPChek (Network + Process checker) is provided by RemsFlems"
Write-Host "----> Lets Start analyzing your system..."
Write-Host "-------------------------"
$output += "----> Welcome to NPcheck.`n"
$output += "----> NPChek (Network + Process checker) is provided by RemsFlems`n"
$output += "----> Lets Start analyzing your system...`n"
$output += "-------------------------`n"
foreach ($pros in $prolist) {
	$tostr = $pros.ProcessId
	$tostrn = $pros.name
	#echo "pid: $tostr"
	#echo "pname: $tostrn"
	Write-Host "[$tostrn]"
	Write-Host "	[NET ACTIVITY]"
	Write-Host "		[TCP]" -noNewLine 
	$output += "[$tostrn]`n"
	$output += "	[NET ACTIVITY]`n"
	$output += "		[TCP]"
	foreach ($nets in $nettcp){
		$netproc = $nets.OwningProcess
		if ($tostr -eq $netproc) {
			$netlocaddr = $nets.LocalAddress
			$netlocport = $nets.LocalPort		
			$netremaddr = $nets.RemoteAddress
			$netremport = $nets.RemotePort

			Write-Host "[L-$netlocaddr" -noNewLine
			Write-Host ":$netlocport R-$netremaddr" -noNewLine
			Write-Host ":$netremport`] " -noNewLine
			$output += "[L-$netlocaddr"
			$output += ":$netlocport R-$netremaddr"
			$output += ":$netremport`] "
		}
	}
	echo ""
	Write-Host "		[UDP]" -noNewLine
	$output += "`n"
	$output += "		[UDP]"
	foreach ($nets in $netudp){
		$netproc = $nets.OwningProcess
		if ($tostr -eq $netproc) {
			$netlocaddr = $nets.LocalAddress
			$netlocport = $nets.LocalPort		
			$netremaddr = $nets.RemoteAddress
			$netremport = $nets.RemotePort

			Write-Host "[L-$netlocaddr" -noNewLine
			Write-Host ":$netlocport R-$netremaddr" -noNewLine
			Write-Host ":$netremport`] " -noNewLine
			$output += "[L-$netlocaddr"
			$output += ":$netlocport R-$netremaddr"
			$output += ":$netremport`] "
		}
	}
	echo ""
	$output += "`n"
	
	Write-Host '	[CORRUPTED DLLs]:'
	$output += "	[CORRUPTED DLLs]:`n"
	$procinfos =Get-Process -ID $tostr 2> $null
	if (-Not($?)) {
		Write-Host "		--CANT LIST MODULES. PID NOT Found!--"
		$output += "		--CANT LIST MODULES. PID NOT Found!--`n"
	} else {
		$proclibs = $procinfos |Select -ExpandProperty modules 2> $null  
		if (-Not($?)) {
			Write-Host "		--CANT LIST MODULES. Permissions Error!--"
			$output += "		--CANT LIST MODULES. Permissions Error!--`n"
		} else {
			Write-Host "		" -noNewLine
			$output += "		"
			foreach ($proclib in $proclibs) {
				$libname = ($proclib).ModuleName
				$libpath = ($proclib).FileName
				
				if ($ListCheckedDll -notcontains $libpath) {
					$scanres = (sfc /verifyfile=$libpath) |Out-String
					$scanres = Format-Result $scanres
					
					#status definition
					#Write-Host $scanres
					$corruptmsg = "*a detecte des violations de l integrite*"
					$cleanmsg = "*aucune violation*"
					if ($scanres -Like $corruptmsg) {
						Write-Host "[$libname`] " -noNewLine
						$output += "[$libname`] "
						$ListBadDll += $libpath 
					} elseif ($scanres -Like $cleanmsg){
						$ListGoodDll += $libpath
					} else {
						$ListUnknownDll += $libpath
					}
					$ListCheckedDll += $libpath				
				} else {
					if ($ListBadDll -contains $libpath) {
							Write-Host "[$libname`] " -noNewLine
							$output += "[$libname`] "
					}
				}
			}
			echo ""
			$output += "`n"
		}
	}
}

#Final result
Write-Host "----------FINAL RESULT-----------"
Write-Host "[CORRUPTED DLLs LIST]"
$output += "----------FINAL RESULT-----------`n"
$output += "[CORRUPTED DLLs LIST]`n"
foreach ($baddll in $ListBadDll) {
	Write-Host "	-> $baddll"
	$output += "	-> $baddll`n"
} 
Write-Output $output > $logfile
