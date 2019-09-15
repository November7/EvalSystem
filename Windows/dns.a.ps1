class Info
{
    [String]$Title
    static [int]$total=0
    static [int]$max=0
    $Grade
    $Value

    Info([String]$t,[Int]$g)
    {
        $this.title = $t
        if($g -ne 0) 
        {
            $this.grade = $g
            $this.value = 0
        }
        [Info]::max += $g
    }
    OK()
    {
        $this.Value = 1;
    }

    [String]check()
    {
        
        if($this.value -eq 1) {[Info]::total += $this.Grade; return "[ TAK ]"}
        elseif($this.value -eq 0) {return "[ NIE ]"}
        else {return ""}
    }
}

function PrintPermissions($p)
{
    Write-Output "-----------------------------------------------------------------------"
    Write-Output "Uprawnienia sieciowe: $p"
    $filter = "Name='$p'"

    $listPermissions = @()

    $myObj = "" | Select Name, AccessMask, AceType          

    foreach( $item in (Get-WmiObject Win32_LogicalShareSecuritySetting -filter $filter).GetSecurityDescriptor().Descriptor.DACL )
    {    
        $myObj.Name = $item.Trustee.Name; 
        Switch ($item.AccessMask)
        {
            2032127 {$myObj.AccessMask = "FullControl";}
            1179785 {$myObj.AccessMask = "Read"}
            1180063 {$myObj.AccessMask = "Read, Write"}
            1179817 {$myObj.AccessMask = "ReadAndExecute"}
            -1610612736 {$myObj.AccessMask = "ReadAndExecuteExtended"}
            1245631 {$myObj.AccessMask = "ReadAndExecute, Modify, Write"}
            1180095 {$myObj.AccessMask = "ReadAndExecute, Write"}
            268435456 {$myObj.AccessMask = "FullControl (Sub Only)"}
            default {$myObj.AccessMask = $item.AccessMask}
        }
        Switch ($item.AceType)
        {
            0 {$myObj.AceType = "Allow"}
            1 {$myObj.AceType = "Deny"}
            2 {$myObj.AceType = "Audit"}
        }    
        $listPermissions += $myObj
    }

    Write-Output ($listPermissions | Format-Table | Out-String)

    Write-Output "Uprawnienia NTFS: $p"

    $results = (Get-Acl ("\\"+$SRVNAME+"\"+$p+"\") | select -ExpandProperty access) | select IdentityReference, FileSystemRights, AccessControlType 
    Write-Output ($results | Format-Table | Out-String)
}

[Info]::max = 0
[Info]::total = 0

###############################################################

# zmienne wynikające z treści zadania


$SRVNAME = "Serwer2008"
$LANIP = "192.168.0.1"
$LANMASK = "255.255.255.128"

$POOLNAME = "Sala38"
$POOLIP = "192.168.0.0"
$POOLMASK = "255.255.255.128"
$POOLTIME = "172800"
$POOLGATE = "192.168.0.1"
$POOLDNS = "192.168.0.1"

$STARTIP = "192.168.0.10"
$ENDIP = "192.168.0.50"

$POOLEX1 = @("192.168.0.15","192.168.0.15")
$POOLEX2 = @("192.168.0.20","192.168.0.30")

$POOLRESIP = "192.168.0.40"
$POOLRESMAC = "00-aa-bb-cc-dd-ee"

$ErrorActionPreference='silentlycontinue'

###############################################################

$tInfo = @()
#-17
$tInfo += New-Object Info("Serwer DNS",0) #0
$tInfo += New-Object Info("Uruchomiony serwer DNS",1) #1
$tInfo += New-Object Info("Nasłuch na interfejsie LAN",5) #2
$tInfo += New-Object Info("Adresy usług przesyłania dalej",5) #3

$tInfo += New-Object Info("Utworzona strefa zsme.local",5) #4
$tInfo += New-Object Info("Domyślny TTL zsme.local",4) #5

$tInfo += New-Object Info("Rekord A zsme.local",3) #6
$tInfo += New-Object Info("TTL dla zsme.local",1) #7
$tInfo += New-Object Info("Rekord A ftp.zsme.local",3) #8
$tInfo += New-Object Info("TTL dla ftp.zsme.local",1) #9
$tInfo += New-Object Info("Rekord CNAME www.zsme.local",3) #10
$tInfo += New-Object Info("TTL dla www.zsme.local",1) #11
$tInfo += New-Object Info("Subdomena biblioteka w zsme.local",4) #12
$tInfo += New-Object Info("Rekord A biblioteka.zsme.local",2) #13
$tInfo += New-Object Info("TTL dla biblioteka.zsme.local",1) #14
$tInfo += New-Object Info("Rekord CNAME www.biblioteka.zsme.local",2) #15
$tInfo += New-Object Info("TTL dla www.biblioteka.zsme.local",1) #16

$tInfo += New-Object Info("Utworzona strefa wyszukiwania wstecz",5) #17
$tInfo += New-Object Info("Rekord PTR zsme.local",2) #18
$tInfo += New-Object Info("TTL PTR zsme.local",1) #19
$tInfo += New-Object Info("Rekord PTR ftp.zsme.local",2) #20
$tInfo += New-Object Info("TTL PTR ftp.zsme.local",1) #21
$tInfo += New-Object Info("Rekord PTR biblioteka.zsme.local",2) #22
$tInfo += New-Object Info("TTL PTR biblioteka.zsme.local",1) #23


###############################################################
# Ustawienia sieci

$MACWAN = (gwmi win32_networkadapter -filter {netconnectionid = "WAN"}).MACAddress
$MACLAN = (gwmi win32_networkadapter -filter {netconnectionid = "LAN"}).MACAddress
$WAN = gwmi win32_networkadapterconfiguration | select * | where MACAddress -eq $MACWAN
$LAN = gwmi win32_networkadapterconfiguration | select * | where MACAddress -eq $MACLAN

$dnssrv = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_Server 


if($dnssrv.Started) {$tInfo[1].OK()}
if($dnssrv.ListenAddresses -eq $LANIP) {$tInfo[2].OK()}
if(($dnssrv.Forwarders | where {$_ -like "8.8.8.8" -or $_ -like "8.8.4.4"} | measure).Count -eq 2) {$tInfo[3].OK()}

$domains = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_Domain
$zsme = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_ResourceRecord | where {$_.DomainName -eq "zsme.local"}
$biblioteka = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_ResourceRecord | where {$_.DomainName -eq "biblioteka.zsme.local"}
$ptr = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_ResourceRecord | where {$_.DomainName -like "*in-addr.arpa*" -and $_.__CLASS -eq "MicrosoftDNS_PTRType"}

if(($domains | where {$_.Name -eq "zsme.local" -and $_.ContainerName -eq "zsme.local"} | measure).Count -eq 1) {$tInfo[4].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_SOAType"}).MinimumTTL -eq 259200) {$tInfo[5].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "zsme.local"}).RecordData -eq "192.168.0.1") {$tInfo[6].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "zsme.local"}).TTL -eq "86400") {$tInfo[7].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "ftp.zsme.local"}).RecordData -eq "192.168.0.2") {$tInfo[8].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "ftp.zsme.local"}).TTL -eq "43200") {$tInfo[9].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.zsme.local"}).RecordData -eq "zsme.local.") {$tInfo[10].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.zsme.local"}).TTL -eq "43200") {$tInfo[11].OK()}

if(($domains | where {$_.Name -eq "biblioteka.zsme.local" -and $_.ContainerName -eq "zsme.local"} | measure).Count -eq 1) {$tInfo[12].OK()}

if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "biblioteka.zsme.local"}).RecordData -eq "192.168.0.10") {$tInfo[13].OK()}
if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "biblioteka.zsme.local"}).TTL -eq "21600") {$tInfo[14].OK()}

if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.biblioteka.zsme.local"}).RecordData -eq "biblioteka.zsme.local.") {$tInfo[15].OK()}
if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.biblioteka.zsme.local"}).TTL -eq "28800") {$tInfo[16].OK()}

if(($domains | where {$_.Name -eq "0.168.192.in-addr.arpa" -and $_.ContainerName -eq "0.168.192.in-addr.arpa"} | measure ).Count -eq 1) {$tInfo[17].OK()}

if(($ptr | where {$_.OwnerName -like "1.0.168.192*"}).RecordData -eq "zsme.local.") {$tInfo[18].OK()}
if(($ptr | where {$_.OwnerName -like "1.0.168.192*"}).TTL -eq "86400") {$tInfo[19].OK()}
if(($ptr | where {$_.OwnerName -like "2.0.168.192*"}).RecordData -eq "ftp.zsme.local.") {$tInfo[20].OK()}
if(($ptr | where {$_.OwnerName -like "2.0.168.192*"}).TTL -eq "43200") {$tInfo[21].OK()}
if(($ptr | where {$_.OwnerName -like "10.0.168.192*"}).RecordData -eq "biblioteka.zsme.local.") {$tInfo[22].OK()}
if(($ptr | where {$_.OwnerName -like "10.0.168.192*"}).TTL -eq "21600") {$tInfo[23].OK()}

###############################################################
# Podsumowanie

$tInfo | Select-Object @{Name="Tytuł";Expression={$_.title}}, @{Name="Waga";Expression={$_.grade}}, @{Name="Poprawnie";Expression={$_.check();}}
Write-Output ("`r`nUzyskałeś {0} / {1} punktów, co stanowi: {2,4:g4}%" -f [Info]::total, [Info]::max, (100*[Info]::total/[Info]::max))