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

$tInfo += New-Object Info("Konfiguracja interfejsów",0) #0
$tInfo += New-Object Info("Nazwa intrerfejsu WAN",2) #1
$tInfo += New-Object Info("Konfiguracja WAN",3) #2
$tInfo += New-Object Info("Nazwa intrerfejsu LAN",2) #3
$tInfo += New-Object Info("Konfiguracja LAN",3) #4

$tInfo += New-Object Info("Serwer DHCP",0)
$tInfo += New-Object Info("Uruchomiony serwer DHCP",1) #6
$tInfo += New-Object Info("Nasłuch na interfejsie LAN",5) #7
$tInfo += New-Object Info("Utworzona pula o nazwie $PULNAME",3) #8
$tInfo += New-Object Info("Maska puli",2) #9
$tInfo += New-Object Info("Zakres IP puli",2) #10
$tInfo += New-Object Info("Wykluczenie $POOLEX1",3) #11
$tInfo += New-Object Info("Wykluczenie $POOLEX2",3) #12
$tInfo += New-Object Info("Czas dzierżawy",2) #13
$tInfo += New-Object Info("Brama domyślna puli",4) #14
$tInfo += New-Object Info("DNS puli",4) #15
$tInfo += New-Object Info("Rezerwacja adresu",5) #16

$tInfo += New-Object Info("Serwer DNS",0) #17
$tInfo += New-Object Info("Uruchomiony serwer DNS",1) #18
$tInfo += New-Object Info("Nasłuch na interfejsie LAN",5) #19
$tInfo += New-Object Info("Adresy usług przesyłania dalej",5) #20

$tInfo += New-Object Info("Utworzona strefa zsme.local",5) #21
$tInfo += New-Object Info("Domyślny TTL zsme.local",4) #22

$tInfo += New-Object Info("Rekord A zsme.local",3) #23
$tInfo += New-Object Info("TTL dla zsme.local",1) #24
$tInfo += New-Object Info("Rekord A ftp.zsme.local",3) #25
$tInfo += New-Object Info("TTL dla ftp.zsme.local",1) #26
$tInfo += New-Object Info("Rekord CNAME www.zsme.local",3) #27
$tInfo += New-Object Info("TTL dla www.zsme.local",1) #28
$tInfo += New-Object Info("Subdomena biblioteka w zsme.local",4) #29
$tInfo += New-Object Info("Rekord A biblioteka.zsme.local",2) #30
$tInfo += New-Object Info("TTL dla biblioteka.zsme.local",1) #31
$tInfo += New-Object Info("Rekord CNAME www.biblioteka.zsme.local",2) #32
$tInfo += New-Object Info("TTL dla www.biblioteka.zsme.local",1) #33

$tInfo += New-Object Info("Utworzona strefa wyszukiwania wstecz",5) #34
$tInfo += New-Object Info("Rekord PTR zsme.local",2) #35
$tInfo += New-Object Info("TTL PTR zsme.local",1) #36
$tInfo += New-Object Info("Rekord PTR ftp.zsme.local",2) #37
$tInfo += New-Object Info("TTL PTR ftp.zsme.local",1) #38
$tInfo += New-Object Info("Rekord PTR biblioteka.zsme.local",2) #39
$tInfo += New-Object Info("TTL PTR biblioteka.zsme.local",1) #40


###############################################################
# Ustawienia sieci

$MACWAN = (gwmi win32_networkadapter -filter {netconnectionid = "WAN"}).MACAddress
$MACLAN = (gwmi win32_networkadapter -filter {netconnectionid = "LAN"}).MACAddress
$WAN = gwmi win32_networkadapterconfiguration | select * | where MACAddress -eq $MACWAN
$LAN = gwmi win32_networkadapterconfiguration | select * | where MACAddress -eq $MACLAN

if( ($MACWAN | measure).count -eq 1 ) {$tInfo[1].OK()}

if( $WAN.IPSubnet[0] -eq "255.0.0.0" -and 
    $WAN.DefaultIPGateway[0] -eq "10.0.0.1" -and
    $WAN.DNSServerSearchOrder[0] -eq "127.0.0.1") {$tInfo[2].OK()}

if( ($MACLAN | measure).count -eq 1 ) {$tInfo[3].OK()}

if( $LAN.IPAddress[0] -eq $LANIP -and
    $LAN.IPSubnet[0] -eq $LANMASK -and 
    !$LAN.DefaultIPGateway -and
    !$LAN.DNSServerSearchOrder) {$tInfo[4].OK()}


if( (netsh dhcp server show server | where {$_ -like "*$SRVNAME*"} | measure).count -eq 1) {$tInfo[6].OK()}

$dhcbind = netsh dhcp server show bindings

if( ($dhcbind | where {$_ -like "*PRAWDA*"} | measure).Count -eq 1 -and
    ($dhcbind | where {$_ -like "*$LANIP*"} | measure).Count -eq 1 ) {$tInfo[7].OK()}



$pool = (netsh dhcp server show scope | where {$_ -like "*$POOLNAME*"}).Split("-") | %{$_.Trim()}

if($pool[0] -eq $POOLIP -and $pool[2] -eq "Aktywny") {$tInfo[8].OK()}
if($pool[1] -eq $POOLMASK) {$tInfo[9].OK()}

if((netsh dhcp server $LANIP scope $POOLIP show iprange | where {$_ -like "*$STARTIP*$ENDIP*"} | measure).count -eq 1) {$tInfo[10].OK()}

$poolexcluded = netsh dhcp server $LANIP scope $POOLIP show excluderange


if(($poolexcluded | where {$_ -like "*"+$POOLEX1[0]+"*"+$POOLEX1[1]+"*"} | measure).count -eq 1) {$tInfo[11].OK()}
if(($poolexcluded | where {$_ -like "*"+$POOLEX2[0]+"*"+$POOLEX2[1]+"*"} | measure).count -eq 1) {$tInfo[12].OK()}

$pooloptions = netsh dhcp server $LANIP scope $POOLIP show optionvalue

if(($pooloptions | select-string "Identyfikator opcji: 51" -Context 0,4 | where {$_ -like "*$POOLTIME*"} | measure).count -eq 1) {$tInfo[13].OK()}
if(($pooloptions | select-string "Identyfikator opcji: 3" -Context 0,4 | where {$_ -like "*$POOLGATE*"} | measure).count -eq 1) {$tInfo[14].OK()}
if(($pooloptions | select-string "Identyfikator opcji: 6" -Context 0,4 | where {$_ -like "*$POOLDNS*"} | measure).count -eq 1) {$tInfo[15].OK()}

if((netsh dhcp server $LANIP scope $POOLIP show reservedip | where {$_ -like "*$POOLRESIP*$POOLRESMAC*"} | measure).count -eq 1) {$tInfo[16].OK()}

$dnssrv = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_Server 


if($dnssrv.Started) {$tInfo[18].OK()}
if($dnssrv.ListenAddresses -eq $LANIP) {$tInfo[19].OK()}
if(($dnssrv.Forwarders | where {$_ -like "8.8.8.8" -or $_ -like "8.8.4.4"} | measure).Count -eq 2) {$tInfo[20].OK()}

$domains = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_Domain
$zsme = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_ResourceRecord | where {$_.DomainName -eq "zsme.local"}
$biblioteka = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_ResourceRecord | where {$_.DomainName -eq "biblioteka.zsme.local"}
$ptr = gwmi -Namespace root\MicrosoftDNS MicrosoftDNS_ResourceRecord | where {$_.DomainName -like "*in-addr.arpa*" -and $_.__CLASS -eq "MicrosoftDNS_PTRType"}

if(($domains | where {$_.Name -eq "zsme.local" -and $_.ContainerName -eq "zsme.local"} | measure).Count -eq 1) {$tInfo[21].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_SOAType"}).MinimumTTL -eq 259200) {$tInfo[22].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "zsme.local"}).RecordData -eq "192.168.0.1") {$tInfo[23].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "zsme.local"}).TTL -eq "86400") {$tInfo[24].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "ftp.zsme.local"}).RecordData -eq "192.168.0.2") {$tInfo[25].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "ftp.zsme.local"}).TTL -eq "43200") {$tInfo[26].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.zsme.local"}).RecordData -eq "zsme.local.") {$tInfo[27].OK()}
if(($zsme | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.zsme.local"}).TTL -eq "43200") {$tInfo[28].OK()}

if(($domains | where {$_.Name -eq "biblioteka.zsme.local" -and $_.ContainerName -eq "zsme.local"} | measure).Count -eq 1) {$tInfo[29].OK()}

if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "biblioteka.zsme.local"}).RecordData -eq "192.168.0.10") {$tInfo[30].OK()}
if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_AType" -and $_.OwnerName -eq "biblioteka.zsme.local"}).TTL -eq "21600") {$tInfo[31].OK()}

if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.biblioteka.zsme.local"}).RecordData -eq "biblioteka.zsme.local.") {$tInfo[32].OK()}
if(($biblioteka | where {$_.__CLASS -eq "MicrosoftDNS_CNAMEType" -and $_.OwnerName -eq "www.biblioteka.zsme.local"}).TTL -eq "28800") {$tInfo[33].OK()}

if(($domains | where {$_.Name -eq "0.168.192.in-addr.arpa" -and $_.ContainerName -eq "0.168.192.in-addr.arpa"} | measure ).Count -eq 1) {$tInfo[34].OK()}

if(($ptr | where {$_.OwnerName -like "1.0.168.192*"}).RecordData -eq "zsme.local.") {$tInfo[35].OK()}
if(($ptr | where {$_.OwnerName -like "1.0.168.192*"}).TTL -eq "86400") {$tInfo[36].OK()}
if(($ptr | where {$_.OwnerName -like "2.0.168.192*"}).RecordData -eq "ftp.zsme.local.") {$tInfo[37].OK()}
if(($ptr | where {$_.OwnerName -like "2.0.168.192*"}).TTL -eq "43200") {$tInfo[38].OK()}
if(($ptr | where {$_.OwnerName -like "10.0.168.192*"}).RecordData -eq "biblioteka.zsme.local.") {$tInfo[39].OK()}
if(($ptr | where {$_.OwnerName -like "10.0.168.192*"}).TTL -eq "21600") {$tInfo[40].OK()}

###############################################################
# Podsumowanie

$tInfo | Select-Object @{Name="Tytuł";Expression={$_.title}}, @{Name="Waga";Expression={$_.grade}}, @{Name="Poprawnie";Expression={$_.check();}}
Write-Output ("`r`nUzyskałeś {0} / {1} punktów, co stanowi: {2,4:g4}%" -f [Info]::total, [Info]::max, (100*[Info]::total/[Info]::max))