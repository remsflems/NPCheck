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


#GET ALL PROCESSES INFOS
$prolist = gwmi win32_process | Sort-Object -Property ProcessId

#Start process verification
#$prolist = Get-CimInstance Win32_Process | Sort-Object -Property ProcessId
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
Write-Host "[NPChek] Lets Start analyzing your system..." -ForegroundColor blue
Write-Host "[INFO] NPChek (Network + Process checker) is provided by RemsFlems" -ForegroundColor blue
$output += "[INFO] Welcome to NPcheck.`n"
$output += "[INFO]NPChek (Network + Process checker) is provided by RemsFlems`n"
$output += "[INFO]Lets Start analyzing your system...`n"
$output += "-------------------------`n"
foreach ($pros in $prolist) {
	$tostr = ($pros |Select ProcessId -ExpandProperty ProcessId)
	$tostrn = ($pros |Select ProcessName -ExpandProperty ProcessName)
	$tostparentid = ($pros |Select ParentProcessId -ExpandProperty ParentProcessId)
	$tostparentname = (gwmi win32_process | Where-Object -Property ProcessID -eq $tostparentid |Select ProcessName -ExpandProperty ProcessName)
	$tostprocmd = ($pros |Select CommandLine -ExpandProperty CommandLine)
	Write-Host "[$tostrn ($tostr)]" -nonewline -ForegroundColor DarkMagenta
	Write-Host "[PARENT:$tostparentname ($tostparentid)]" -nonewline -ForegroundColor blue
	Write-Host "[CMD: $tostprocmd]" -ForegroundColor DarkYellow
	$output += "[$tostrn ($tostr)] [PARENT:$tostparentname ($tostparentid)] [CMD: $tostprocmd]`n"
	$netaction = 0
	foreach ($nets in $nettcp){
		$netproc = $nets.OwningProcess
		if ($tostr -eq $netproc) {
			$netaction += 1
			if ($netaction -eq 1) {
				Write-Host "	[NET ACTIVITY]"
				$output += "	[NET ACTIVITY]`n"
			}
			Write-Host "		[TCP]" -noNewLine 
			$output += "		[TCP]"
			$netlocaddr = $nets.LocalAddress
			$netlocport = $nets.LocalPort		
			$netremaddr = $nets.RemoteAddress
			$netremport = $nets.RemotePort
			Write-Host "[L-$netlocaddr" -noNewLine
			Write-Host ":$netlocport R-$netremaddr" -noNewLine
			Write-Host ":$netremport`] "
			$output += "[L-$netlocaddr"
			$output += ":$netlocport R-$netremaddr"
			$output += ":$netremport`] "
		}
	}
	#echo ""
	#$output += "`n"
	foreach ($nets in $netudp){
		$netproc = $nets.OwningProcess
		if ($tostr -eq $netproc) {
			$netaction += 1
			if ($netaction -eq 1) {
				Write-Host "	[NET ACTIVITY]"
				$output += "	[NET ACTIVITY]`n"
			}
			Write-Host "		[UDP]" -noNewLine
			$output += "		[UDP]"
			$netlocaddr = $nets.LocalAddress
			$netlocport = $nets.LocalPort		
			$netremaddr = $nets.RemoteAddress
			$netremport = $nets.RemotePort

			Write-Host "[L-$netlocaddr" -noNewLine
			Write-Host ":$netlocport R-$netremaddr" -noNewLine
			Write-Host ":$netremport`] "
			$output += "[L-$netlocaddr"
			$output += ":$netlocport R-$netremaddr"
			$output += ":$netremport] `n"
		}
	}
	$dllcorruptcount = 0
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
						$dllcorruptcount += 1
						if ( $dllcorruptcount -eq 1) {
							Write-Host '	[CORRUPTED DLLs]:'
							$output += "	[CORRUPTED DLLs]:`n"
						}
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
						$dllcorruptcount += 1
						if ( $dllcorruptcount -eq 1) {
							Write-Host '	[CORRUPTED DLLs]:'
							$output += "	[CORRUPTED DLLs]:`n"
						}
						Write-Host "[$libname`] " -noNewLine
						$output += "[$libname`] "
					}
				}
			}
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
