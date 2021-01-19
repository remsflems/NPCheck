

#VERIFICATION OF RUNNING AS ROOT
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$a = ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
if ($a -eq "True") {
	Write-Host "I AM ADMIN"
}else {
	Write-Host "[ERROR] This has to be run AS ADMINISTRATOR PRIVILEGES..exiting.."
	Exit
}
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Write-Host $scriptPath
Set-Location -Path $scriptPath
Exit

###THE System, Network and Process verification Tool -remsflems
Write-Host "[SNPver] [Version 1.2" -ForegroundColor green
Write-Host "[DESCRIPTION] The System Network & Processus Verification Tool" -ForegroundColor green
Write-Host "[INCLUDING] NPcheck - The Network & Process Checking tool"
Write-Host "[COPYRGHT] All credit reserved for SNpver (including NPcheck) to RemsFlems" -ForegroundColor red
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
$totalramkil = ($Computerinfos |Select OsTotalVisibleMemorySize -ExpandProperty OsTotalVisibleMemorySize)
$usedramkil = ($Computerinfos |Select OsInUseVirtualMemory -ExpandProperty OsInUseVirtualMemory)
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



$totalram = [math]::Round($totalramkil /1024/1024,1)
$usedram = [math]::Round($usedramkil /1024/1024,1)


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
	$disksize = ($_ | Select Size -ExpandProperty Size)
	$diskbus = ($_ | Select BusType -ExpandProperty BusType)
	$diskhealth = ($_ | Select HealthStatus -ExpandProperty HealthStatus)
	$diskpart = ($_ | Select PartitionStyle -ExpandProperty PartitionStyle)
	$diskstatus = ($_ | Select OperationalStatus -ExpandProperty OperationalStatus)
	Write-Host "	$diskmodel - $disksize - $diskpart - $diskbus - $diskhealth - $diskstatus"
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
Write-Host '[DEEP SCAN]'  -nonewline -ForegroundColor red
$ContinueScan = Read-Host -Prompt " Would you like to perform a deep scan using NPcheck(Y/n)?"
if ($ContinueScan -eq "Y") {
.\NPCheck.ps1
}






