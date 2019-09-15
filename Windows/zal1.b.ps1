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

$IP = "192.168.0.10"
$MASK = "255.255.255.128"
$GATE = "192.168.0.1"
$DNS = "127.0.0.1"

$SRVNAME = "SerwerABC"
$DOMAIN = "abc.local"

$USR1LOGIN = "kierownik"
$USR2LOGIN = "pracownik"

$USR1 = (Get-ADUser -filter {SamAccountName -eq $USR1LOGIN} -Properties *)
$USR2 = (Get-ADUser -filter {SamAccountName -eq $USR2LOGIN} -Properties *)


$GRP1 = "UsersABC"
$PC1 = "Stanowisko"

$LOCALHOMEDIR = "C:\dane"
$HOMEDRIVE = "Q:"

$PROFDIR = "profile_mobilne"
$SHPROFDIR = $PROFDIR+"$"

$HOMEDIR = "foldery_macierzyste"
$SHOMEDIR = $HOMEDIR

$ErrorActionPreference='silentlycontinue'

###############################################################


$tInfo = @()

$tInfo += New-Object Info("Konfiguracja sieciowa",0)
$tInfo += New-Object Info("- Adres IP ($IP)",1) #1
$tInfo += New-Object Info("- Maska podsieci ($MASK)",1) #2
$tInfo += New-Object Info("- Brama domyślna ($GATE)",1) #3
$tInfo += New-Object Info("- Adres serwera DNS ($DNS)",2) #4

$tInfo += New-Object Info("Konstroler domeny",0)
$tInfo += New-Object Info("- Nazwa serwera ($SRVNAME)",2) #6
$tInfo += New-Object Info("- Zainstalowany kontroler domeny",5) #7
$tInfo += New-Object Info("- Nazwa domeny ($DOMAIN)",2) #8
$tInfo += New-Object Info("- Poziom funkcjonalności domeny",2) #9

$tInfo += New-Object Info("Użytkownicy AD",0)
$tInfo += New-Object Info("- Użytkownik ($USR1LOGIN)",2) #11
$tInfo += New-Object Info("- Użytkownik ($USR2LOGIN)",2) #12
$tInfo += New-Object Info("- Stworzona grupa ($GRP1)",2) #13
$tInfo += New-Object Info("- Użytkownicy w grupie ($GRP1)",2) #14

$tInfo += New-Object Info("Utworzone i udostępnionwe foldery",0)
$tInfo += New-Object Info("- Udostępniony folder (profil mobilny)",1) #16
$tInfo += New-Object Info("- Udostępniony folder (folder macierzysty)",1) #17

$tInfo += New-Object Info("Parametry kont użytkowników",0) #18
$tInfo += New-Object Info("- Godziny logowania ($USR1LOGIN)",2) #19
$tInfo += New-Object Info("- Zasady hasła ($USR1LOGIN)",2) #20
$tInfo += New-Object Info("- Profil mobilny ($USR1LOGIN)",3) #21
$tInfo += New-Object Info("- Folder macierzysty ($USR1LOGIN)",3) #22

$tInfo += New-Object Info("- Wygasanie konta ($USR2LOGIN)",2) #23
$tInfo += New-Object Info("- Zasady hasła ($USR2LOGIN)",2) #24
$tInfo += New-Object Info("- Profil mobilny ($USR2LOGIN)",3) #25
$tInfo += New-Object Info("- Folder macierzysty ($USR2LOGIN)",3) #26

$tInfo += New-Object Info("Komputer w domenie",0)
$tInfo += New-Object Info("- Konto komputera ($PC1)",3) #28
$tInfo += New-Object Info("- Komputer dołączony do domeny",5) #29

$tInfo += New-Object Info("Uprawnienia udziałów (ocenianie ręczne)",0) #30
$tInfo += New-Object Info("- Uprawnienia sieciowe ($SHPROFDIR)",2) #31
$tInfo += New-Object Info("- Uprawnienia NTFS ($SHPROFDIR)",2) #32
$tInfo += New-Object Info("- Uprawnienia sieciowe ($SHOMEDIR)",2) #33
$tInfo += New-Object Info("- Uprawnienia NTFS ($SHOMEDIR)",2) #34


###############################################################
# Ustawienia sieci
$netObj = (Get-WmiObject -class win32_networkadapterconfiguration -filter "ipenabled = true" -ComputerName . | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*)


if($netObj.IPAddress[0] -eq $IP) {$tInfo[1].OK()}
if($netObj.IPSubnet[0] -eq $MASK) {$tInfo[2].OK()}
if($netObj.DefaultIPGateway[0] -eq $GATE) {$tInfo[3].OK()}
if($netObj.DNSServerSearchOrder[0] -eq $DNS) {$tInfo[4].OK()}

if($netObj.PSComputerName -eq $SRVNAME) {$tInfo[6].OK()}
if((Get-ADDomainController).Enabled) {$tInfo[7].OK()}
if($netObj.DNSDomainSuffixSearchOrder[0] -eq $DOMAIN) {$tInfo[8].OK()}
if((Get-ADDomain).DomainMode -eq "Windows2008R2Domain") {$tInfo[9].OK()}

if(($USR1 | measure).Count -eq 1) {$tInfo[11].OK()}
if(($USR2 | measure).Count -eq 1) {$tInfo[12].OK()}
if((Get-ADGroup -filter {Name -eq $GRP1 -and GroupScope -eq "Global" -and GroupCategory -eq "Security"} | measure).Count -eq 1) {$tInfo[13].OK()}
if(((Get-ADPrincipalGroupMembership -Identity $USR1).name) -contains $GRP1 -and
   ((Get-ADPrincipalGroupMembership -Identity $USR2).name) -contains $GRP1) {$tInfo[14].OK()}

if(((Get-WmiObject win32_share | where {$_.Name -eq $SHPROFDIR -and $_.Path -eq "C:\"+$PROFDIR} | select Name,Path) | measure).Count -eq 1) {$tInfo[16].OK()}
if(((Get-WmiObject win32_share | where {$_.Name -eq $SHOMEDIR -and $_.Path -eq "C:\"+$HOMEDIR} | select Name,Path) | measure).Count -eq 1) {$tInfo[17].OK()}

if(-not (Compare-Object $USR1.logonHours (0,0,0,0,0,255,0,0,255,0,0,255,0,0,255,0,0,255,0,0,0))) {$tInfo[19].OK()}
if($USR1.PasswordNeverExpires) {$tInfo[20].OK()}

if($USR1.ProfilePath -eq "\\"+$SRVNAME+"\"+$SHPROFDIR+"\"+$USR1Login) {$tInfo[21].OK()}
if($USR1.HomeDirectory -eq $LOCALHOMEDIR) {$tInfo[22].OK()}

if($USR2.AccountExpirationDate -eq "2017-07-01 00:00:00") {$tInfo[23].OK()}
if($USR2.CannotChangePassword) {$tInfo[24].OK()}

if($USR2.ProfilePath -eq "\\"+$SRVNAME+"\"+$SHPROFDIR+"\"+$USR2Login) {$tInfo[25].OK()}
if($USR2.HomeDirectory -eq "\\"+$SRVNAME+"\"+$SHOMEDIR+"\"+$USR2Login -and $USR2.HomeDrive -eq $HOMEDRIVE) {$tInfo[26].OK()}

if((Get-ADComputer -filter {Name -eq $PC1} | measure).Count -eq 1) {$tInfo[28].OK()}
if(((Get-ADComputer -filter {Name -eq $PC1 -and lastLogon -ne 0 }) | measure).Count -eq 1) {$tInfo[29].OK()}


PrintPermissions($SHPROFDIR)
$rk = Read-Host -Prompt "Uprawnienia sieciowe ($SHPROFDIR)"
if($rk -gt 0) {$tInfo[31].OK()}
$rk = Read-Host -Prompt "Uprawnienia NTFS ($SHPROFDIR)"
if($rk -gt 0) {$tInfo[32].OK()}

PrintPermissions($SHOMEDIR)
$rk = Read-Host -Prompt "Uprawnienia sieciowe ($SHOMEDIR)"
if($rk -gt 0) {$tInfo[33].OK()}
$rk = Read-Host -Prompt "Uprawnienia NTFS ($SHOMEDIR)"
if($rk -gt 0) {$tInfo[34].OK()}


###############################################################
# Podsumowanie

$tInfo | Select-Object @{Name="Tytuł";Expression={$_.title}}, @{Name="Waga";Expression={$_.grade}}, @{Name="Poprawnie";Expression={$_.check();}}
Write-Output ("`r`nUzyskałeś {0} / {1} punktów, co stanowi: {2,4:g4}%" -f [Info]::total, [Info]::max, (100*[Info]::total/[Info]::max))