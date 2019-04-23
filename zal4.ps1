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

$USRLOGIN = "jnowak"
$GROUP = "UsersFTP"
$IP1 = "10.38.*.1"
$IP2 = "10.38.*.2"



$ZONE1 = "zsme.local"
$ZONE2 = "biblioteka.local"

$SITE1 = "zsme"
$SITE2 = "biblioteka"
$SITE3 = "ftp_pub"


$ErrorActionPreference='silentlycontinue'

###############################################################

$tInfo = @()
$tInfo += New-Object Info("",0) #0
$tInfo += New-Object Info("Konfiguracja sieci, użytkownik i grupa",0) #1
$tInfo += New-Object Info("- Adresy IP: $IP1, $IP2",4) #2
$tInfo += New-Object Info("- Utworzony użytkownik $USRLOGIN",1) #3
$tInfo += New-Object Info("- Utworzona grupa $GROUP",1) #4
$tInfo += New-Object Info("- Użytkownik $USERLOGIN dodany do grupy $GROUP",1) #5

$tInfo += New-Object Info("",0) #6
$tInfo += New-Object Info("Serwer DNS",0) #7
$tInfo += New-Object Info("- Utworzona strefa $ZONE1",3) #8
$tInfo += New-Object Info("- Utworzony host $ZONE1",3) #9
$tInfo += New-Object Info("- Utworzony host ftp.$ZONE1",3) #10
$tInfo += New-Object Info("- Utworzony alias www.$ZONE1",3) #11
$tInfo += New-Object Info("- Utworzona strefa $ZONE2",3) #12
$tInfo += New-Object Info("- Utworzony host $ZONE2",3) #13
$tInfo += New-Object Info("- Utworzony alias www.$ZONE2",3) #14
$tInfo += New-Object Info("",0) #15
$tInfo += New-Object Info("Serwer IIS",0) #16
$tInfo += New-Object Info("- Utworzona witryna $SITE1",1) #17
$tInfo += New-Object Info("- Utworzona witryna $SITE2",1) #18
$tInfo += New-Object Info("- Utworzona witryna $SITE3",1) #19
$tInfo += New-Object Info("",0) #20
$tInfo += New-Object Info("Konfiguraja witryny $SITE1",0) #21
$tInfo += New-Object Info("- włączona witryna",3) #22
$tInfo += New-Object Info("- typ witryny (FTP, HTTP)",3) #23
$tInfo += New-Object Info("- lokalizacja fizyczna",3) #24
$tInfo += New-Object Info("- powiązania (ip:port, host)",6) #25
$tInfo += New-Object Info("- domyślny dokument (HTTP)",3) #26
$tInfo += New-Object Info("- Uwierzytelnianie (FTP)",3) #27
$tInfo += New-Object Info("- Reguły autoryzacji (FTP)",3) #28
$tInfo += New-Object Info("- Uprawnienia (FTP)",3) #29
$tInfo += New-Object Info("",0) #30
$tInfo += New-Object Info("Konfiguraja witryny $SITE2",0) #31
$tInfo += New-Object Info("- włączona witryna",3) #32
$tInfo += New-Object Info("- typ witryny (HTTP)",3) #33
$tInfo += New-Object Info("- lokalizacja fizyczna",3) #34
$tInfo += New-Object Info("- powiązania (ip:port, host)",6) #35
$tInfo += New-Object Info("- domyślny dokument (HTTP)",3) #36
$tInfo += New-Object Info("",0) #37
$tInfo += New-Object Info("Konfiguraja witryny $SITE3",0) #38
$tInfo += New-Object Info("- włączona witryna",3) #39
$tInfo += New-Object Info("- typ witryny (FTP)",3) #40
$tInfo += New-Object Info("- lokalizacja fizyczna",3) #41
$tInfo += New-Object Info("- powiązania (ip:port, host)",6) #42
$tInfo += New-Object Info("- Uwierzytelnianie (FTP)",3) #43
$tInfo += New-Object Info("- Reguły autoryzacji (FTP)",3) #44
$tInfo += New-Object Info("- Uprawnienia (FTP)",3) #45

###############################################################

$tip = (gwmi win32_networkadapterconfiguration).ipaddress | where {$_ -like "*.*.*.*"}

if(($tip | where {$_ -like $IP1} | measure).Count -eq 1 -and ($tip | where {$_ -like $IP2} | measure).Count -eq 1) {$tInfo[2].OK()}
if((gwmi win32_useraccount -Namespace "root\cimv2" | where name -eq $USRLOGIN | measure).Count -eq 1) {$tInfo[3].OK()}
if((gwmi win32_group | where {$_.Name -eq $GROUP} | measure).Count -eq 1) {$tInfo[4].OK()}
if((gwmi win32_groupuser | where groupcomponent -like "*$GROUP*").partcomponent -like "*$USRLOGIN*") {$tInfo[5].OK()}

if((gwmi microsoftDNS_zone -Namespace root\microsoftDNS | where Name -eq "zsme.local" | measure).count -eq 1) {$tInfo[8].OK()}
if((gwmi microsoftDNS_AType -Namespace root\microsoftDNS | where {$_.containername -eq "zsme.local" -and $_.OwnerName -eq "zsme.local"}).RecordData -like $IP1) {$tInfo[9].OK()}
if((gwmi microsoftDNS_AType -Namespace root\microsoftDNS | where {$_.containername -eq "zsme.local" -and $_.OwnerName -eq "ftp.zsme.local"}).RecordData -like $IP2) {$tInfo[10].OK()}
if((gwmi microsoftDNS_CNAMEType -Namespace root\microsoftDNS | where {$_.containername -eq "zsme.local" -and $_.OwnerName -eq "www.zsme.local"}).RecordData -eq "zsme.local.") {$tInfo[11].OK()}
if((gwmi microsoftDNS_zone -Namespace root\microsoftDNS | where Name -eq "zsme.local" | measure).count -eq 1) {$tInfo[12].OK()}
if((gwmi microsoftDNS_AType -Namespace root\microsoftDNS | where {$_.containername -eq "biblioteka.local" -and $_.OwnerName -eq "biblioteka.local"}).RecordData -like $IP1) {$tInfo[13].OK()}
if((gwmi microsoftDNS_CNAMEType -Namespace root\microsoftDNS | where {$_.containername -eq "biblioteka.local" -and $_.OwnerName -eq "www.biblioteka.local"}).RecordData -eq "biblioteka.local.") {$tInfo[14].OK()}

$iis = Get-Website | select *

if(($iis | where Name -eq "zsme" | measure).count -eq 1) {$tInfo[17].OK()}
if(($iis | where Name -eq "biblioteka" | measure).count -eq 1) {$tInfo[18].OK()}
if(($iis | where Name -eq "ftp_pub" | measure).count -eq 1) {$tInfo[19].OK()}

$zsme = $iis | where {$_.Name -eq "zsme"}

if($zsme.state -eq "Started" -and $zsme.ftpServer.state -eq "Started") {$tInfo[22].OK()}
if(($zsme.bindings.Collection.protocol | where {$_ -eq "http"} | measure).Count -gt 0 -and ($zsme.bindings.Collection.protocol | where {$_ -eq "ftp"} | measure).Count -eq 1) {$tInfo[23].OK()}
if($zsme.physicalPath -eq "c:\serwer_www\zsme") {$tInfo[24].OK()}
if($zsme.bindings.Collection.bindingInformation -like "10.38.*.1:80:zsme.local" -and 
   $zsme.bindings.Collection.bindingInformation -like "10.38.*.1:80:www.zsme.local" -and 
   $zsme.bindings.Collection.bindingInformation -like "10.38.*.1:21:") {$tInfo[25].OK()}


if(!$zsme.ftpServer.security.authentication.anonymousAuthentication.enabled -and $zsme.ftpServer.security.authentication.basicAuthentication.enabled)  {$tInfo[27].OK()}

$biblioteka = $iis | where {$_.Name -eq "biblioteka"}

if($biblioteka.state -eq "Started") {$tInfo[32].OK()}
if(($biblioteka.bindings.Collection.protocol | where {$_ -eq "http"} | measure).Count -gt 0) {$tInfo[33].OK()}
if($biblioteka.physicalPath -eq "c:\serwer_www\biblioteka") {$tInfo[34].OK()}
if($biblioteka.bindings.Collection.bindingInformation -like "10.38.*.1:80:biblioteka.local" -and 
   $biblioteka.bindings.Collection.bindingInformation -like "10.38.*.1:80:www.biblioteka.local") {$tInfo[35].OK()}

$ftp_pub = $iis | where {$_.Name -eq "ftp_pub"}
if($ftp_pub.state -eq "Started") {$tInfo[39].OK()}
if(($ftp_pub.bindings.Collection.protocol | where {$_ -eq "ftp"} | measure).Count -eq 1) {$tInfo[40].OK()}
if($ftp_pub.physicalPath -eq "c:\serwer_ftp\publiczny") {$tInfo[41].OK()}
if($ftp_pub.bindings.Collection.bindingInformation -like "10.38.*.2:21:") {$tInfo[42].OK()}
if($ftp_pub.ftpServer.security.authentication.anonymousAuthentication.enabled -and !$ftp_pub.ftpServer.security.authentication.basicAuthentication.enabled)  {$tInfo[43].OK()}

if((Get-WebConfigurationProperty -filter "//defaultDocument/files/add" -PSPath 'IIS:\Sites\zsme' -Name "value" | select value)[0].value -eq "index.html") {$tInfo[26].OK()}
if((Get-WebConfigurationProperty -filter "//defaultDocument/files/add" -PSPath 'IIS:\Sites\biblioteka' -Name "value" | select value)[0].value -eq "start.html") {$tInfo[36].OK()}

###############################################################
# Podsumowanie

$tInfo | Select-Object @{Name="Tytuł";Expression={$_.title}}, @{Name="Waga";Expression={$_.grade}}, @{Name="Poprawnie";Expression={$_.check();}}
Write-Output ("`r`nUzyskałeś {0} / {1} punktów, co stanowi: {2,4:g4}%" -f [Info]::total, [Info]::max, (100*[Info]::total/[Info]::max))