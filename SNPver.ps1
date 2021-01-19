###THE System, Network and Process verification Tool -remsflems
Write-Host "[SNPver] [Version 1.2]" -ForegroundColor green

#$ErrorActionPreference = 'silentlycontinue'
###VERIFICATION OF RUNNING AS ROOT

function ChekIfRoot() {
	$currentPrincipal = New-Object security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	$a = ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
	if ($a -ne "True") {
		Write-Host "[ERROR] This has to be run AS ADMINISTRATOR PRIVILEGES..exiting.."
		Exit
	}
	$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
	Write-Host $scriptPath
	Set-Location -Path $scriptPath
}

#ChekIfRoot

Write-Host "[Info] Retrieving system informations"
Write-Host "	[DESCRIPTION] The System Network & Processus Verification Tool" -ForegroundColor green
Write-Host "	[INCLUDING] NPcheck - The Network & Process Checking tool"
Write-Host "	[COPYRGHT] All credit reserved for SNpver (including NPcheck) to RemsFlems" -ForegroundColor darkred
$Computerinfos = (Get-ComputerInfo)
$winname = ($Computerinfos |Select WindowsProductName -ExpandProperty WindowsProductName)
$winversion = ($Computerinfos |Select WindowsVersion -ExpandProperty WindowsVersion)
$winarchi = ($Computerinfos |Select OsArchitecture -ExpandProperty OsArchitecture)
$biosinfos = ($Computerinfos |Select BiosBIOSVersion -ExpandProperty BiosBIOSVersion)
$biostype = ($Computerinfos |Select BiosFirmwareType -ExpandProperty BiosFirmwareType)
$sysname = ($Computerinfos |Select CsName -ExpandProperty CsName)
$sysDNSname = ($Computerinfos |Select CsDNSHostName -ExpandProperty CsDNSHostName)
$netdomaine = ($Computerinfos |Select CsDomain -ExpandProperty CsDomain)
$netpath = ($Computerinfos |Select LogonServer -ExpandProperty LogonServer)
$netadapters = ($Computerinfos |Select CsNetworkAdapters -ExpandProperty CsNetworkAdapters)
$totalramkill = ($Computerinfos |Select OsTotalVisibleMemorySize -ExpandProperty OsTotalVisibleMemorySize)
$usedramkill = ($Computerinfos |Select OsInUseVirtualMemory -ExpandProperty OsInUseVirtualMemory)
$adminuser = ($Computerinfos |Select CsPrimaryOwnerName -ExpandProperty CsPrimaryOwnerName)
$pcmanufacturer = ($Computerinfos |Select CsManufacturer -ExpandProperty CsManufacturer).Trim()
$pcmodel = ($Computerinfos |Select CsModel -ExpandProperty CsModel)

$users = (Get-LocalUser)

$processeur = ( Get-CimInstance -ClassName Win32_Processor)
$cpuinfos = ($processeur | Select Name -ExpandProperty Name)

$raminfos = (Get-CimInstance Win32_physicalMemory)

$graphicard = (Get-WmiObject Win32_VideoController)

$disks = (Get-Disk)

$lastupdatedate = (Get-CimInstance -ClassName Win32_QuickFixEngineering |Sort-Object -Property InstalledOn -Descending |Select-Object -First 1 | Select InstalledOn -ExpandProperty InstalledOn )
$updatelist = ( Get-CimInstance -ClassName Win32_QuickFixEngineering |Sort-Object -Property InstalledOn -Descending )



$totalram = [math]::Round($totalramkill /1024/1024,1)
$usedram = [math]::Round($usedramkill /1024/1024,1)


Write-Host "-------INFOS GENERALES" -ForegroundColor green
Write-Host "[INFOS] " -nonewline -ForegroundColor blue; Write-Host "$winname - v$winversion - $winarchi"
Write-Host "[BIOS] " -nonewline -ForegroundColor blue; Write-Host "$biosinfos - $biostype"
Write-Host "[PC-NAME] " -nonewline -ForegroundColor blue; Write-Host "$sysname"
Write-Host "[ADMIN USER] " -nonewline -ForegroundColor blue; Write-Host "$adminuser"
Write-Host "[UTLISATEURS] " -nonew -ForegroundColor blue
$users |Foreach-Object {
	$uname = ($_ |Select Name -ExpandProperty Name)
	$ustatus = ($_ |Select Enabled -ExpandProperty Enabled)
	if ($ustatus -eq "True") { 
		Write-Host "	$uname - actif"
	} else { 
		Write-Host "	$uname - inactif"
	}
}
Write-Host "[MISE A JOUR] " -nonewline -ForegroundColor blue; Write-Host "$lastupdatedate"
$updatelist |Foreach-Object {
	$majname = ($_ | Select HotFixID -ExpandProperty HotFixID)
	$majdate = ($_ | Select InstalledOn -ExpandProperty InstalledOn)
	$majinfo = ($_ | Select Description -ExpandProperty Description)
	Write-Host "	$majname - $majdate - $majinfo"
}

Write-Host "-------SYSTEME" -ForegroundColor green
Write-Host "[TYPE] " -nonewline -ForegroundColor blue; Write-Host "$pcmanufacturer - $pcmodel"
Write-Host "[CPU] " -nonewline -ForegroundColor blue; Write-Host "$cpuinfos"
Write-Host "[UTILISATION RAM] " -nonewline -ForegroundColor blue; Write-Host "$usedram / $totalram Gio"
$raminfos |foreach-Object {
	$manufacturer = ($_ | select Manufacturer -ExpandProperty Manufacturer)
	$ramdetail = ($_ | select PartNumber -ExpandProperty PartNumber).Trim()
	$ramspeed = ($_ | select Speed -ExpandProperty Speed)
	Write-Host "[RAM] " -nonewline -ForegroundColor blue; Write-Host "$manufacturer - $ramdetail - $ramspeed Mhz"
}
Write-Host "[CARTES GRAPHIQUE] " -ForegroundColor blue
$graphicard |Foreach-Object{
	$cgname = ( $_ | Select Name -ExpandProperty Name)
	$cgstatus = ( $_ | Select Status -ExpandProperty Status)
	$cgramoct = ( $_ | Select AdapterRAM -ExpandProperty AdapterRAM)
	$cgram = $cgramoct /1024 / 1024 / 1024 
	$cgvideomode = ( $_ | Select VideoModeDescription -ExpandProperty VideoModeDescription)
	Write-Host "	$cgname - $cgram Gio - $cgstatus - $cgvideomode"
}

Write-Host "[DISKS] "  -ForegroundColor blue
$disks | Foreach-Object {
	$diskmodel = ($_ | Select Model -ExpandProperty Model)
	$disksizeoct = ($_ | Select Size -ExpandProperty Size)
	$disksize = [math]::Round($disksizeoct / 1024 /1024 / 1024,1)
	$diskbus = ($_ | Select BusType -ExpandProperty BusType)
	$diskhealth = ($_ | Select HealthStatus -ExpandProperty HealthStatus)
	$diskpart = ($_ | Select PartitionStyle -ExpandProperty PartitionStyle)
	$diskstatus = ($_ | Select OperationalStatus -ExpandProperty OperationalStatus)
	Write-Host "	$diskmodel - $disksize Gio - $diskpart - $diskbus - $diskhealth - $diskstatus"
}
Write-Host "-------RESEAU" -ForegroundColor green
Write-Host "[DOMAINE] " -nonewline -ForegroundColor blue; Write-Host "$netdomaine"
Write-Host "[NET-PC-NAME] " -nonewline -ForegroundColor blue; Write-Host "$sysDNSname"
Write-Host "[CHEMIN] " -nonewline -ForegroundColor blue; Write-Host "$netpath"

#$netadapters
Write-Host "[CARTES RESEAU] " -ForegroundColor blue
$netadapters |foreach-Object { 
	$type = ($_ | select ConnectionID -ExpandProperty ConnectionID)
	$desc = ($_ | select Description -ExpandProperty Description)
	Write-Host "	[$type] - $desc"
	$ipaddrs = ( $_ | select IPAddresses -ExpandProperty IPAddresses)
	$ipaddrs |foreach-Object {
		Write-Host "		IP: $_"
	}
	
}

#Processus and network analyze
function NPcheck() {
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
}

Write-Host '[DEEP SCAN]'  -nonewline -ForegroundColor red
$ContinueScan = Read-Host -Prompt " Would you like to perform a deep scan using NPcheck(Y/n)?"
if ($ContinueScan -eq "Y") {
	NPCheck
}

Read-Host -Prompt "Press Enter to exit"





