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

$USRLOGIN = "nauczyciel"

$USR = (Get-ADUser -filter {SamAccountName -eq $USRLOGIN} -Properties *)

$OU = "Pracownicy"
$OUDEL = "Sala39"
$PC = "Komputer1"

$CFILES = "pliki"
$CPRIV = "dane_osobiste"

$GPSTARTER = "Szablon"
$GPO = "Pracownia38"

$SRVNAME = "Windows2008"

$ErrorActionPreference='silentlycontinue'

###############################################################

$tInfo = @()

$tInfo += New-Object Info("Użytkownicy AD",0) #0
$tInfo += New-Object Info("- Użytkownik ($USRLOGIN)",3) #1
$tInfo += New-Object Info("- Utworzona jednostka organizacyjna ($OU)",3) #2
$tInfo += New-Object Info("- Usunięta jednostka organizacyjna ($OUDEL)",5) #3
$tInfo += New-Object Info("- Użytkownik ($USRLOGIN) dodany do jednostki ($OU)",5) #4

$tInfo += New-Object Info("Utworzone i udostępnionwe foldery",0) #5
$tInfo += New-Object Info("- Udostępniony folder (C:\pliki)",3) #6
$tInfo += New-Object Info("- Udostępniony folder (C:\dane_osobiste)",3) #7

$tInfo += New-Object Info("Uprawnienia udziałów (ocenianie ręczne)",0) #8
$tInfo += New-Object Info("- Uprawnienia sieciowe ($CFILES)",3) #9
$tInfo += New-Object Info("- Uprawnienia NTFS ($CFILES)",3) #10
$tInfo += New-Object Info("- Uprawnienia sieciowe ($CPRIV)",3) #11
$tInfo += New-Object Info("- Uprawnienia NTFS ($CPRIV)",3) #12

$tInfo += New-Object Info("Komputer w domenie",0) #13
$tInfo += New-Object Info("- Konto komputera ($PC)",4) #14
$tInfo += New-Object Info("- Komputer ($PC) dołączony do domeny",4) #15

$tInfo += New-Object Info("Obiekty GPO",0) #16
$tInfo += New-Object Info("- Obiekt startowy ($GPSTARTER)",6) #17
$tInfo += New-Object Info("- Konfiguracja menu start 1 ($GPSTARTER)",4) #18
$tInfo += New-Object Info("- Konfiguracja menu start 2 ($GPSTARTER)",4) #19
$tInfo += New-Object Info("- Konfiguracja pulpitu - kosz ($GPSTARTER)",4) #20
$tInfo += New-Object Info("- Obiekt GPO ($GPO)",5) #21
$tInfo += New-Object Info("- Wyłączona gałąź konfiguracji komputera ($GPO)",4) #22
$tInfo += New-Object Info("- Obiekt ($GPO) podlinkowany do $OU",4) #23
$tInfo += New-Object Info("- Konfiguracja menu start 1 ($GPO)",1) #24
$tInfo += New-Object Info("- Konfiguracja menu start 2 ($GPO)",1) #25
$tInfo += New-Object Info("- Konfiguracja pulpitu - kosz ($GPO)",1) #26
$tInfo += New-Object Info("- Przekierowanie folderu Dokumenty ($GPO)",8) #27
$tInfo += New-Object Info("- Przekierowanie folderu Menu Start ($GPO)",8) #28
$tInfo += New-Object Info("- Tapeta pulpitu ($GPO)",4) #29
$tInfo += New-Object Info("- Wyłącz element ekran w panelu sterowania ($GPO)",4) #30

###############################################################

if(($USR | measure).Count -eq 1) {$tInfo[1].OK()}
if((Get-ADOrganizationalUnit -Filter {Name -eq $OU} | measure).Count -eq 1) {$tInfo[2].OK()}
if((Get-ADOrganizationalUnit -Filter {Name -eq $OUDEL} | measure).Count -eq 0) {$tInfo[3].OK()}
if((Get-ADUSer -Filter {SamAccountName -eq $USRLOGIN} -SearchBase "ou=$OU,dc=zsme,dc=local" | measure).Count -eq 1) {$tInfo[4].OK()}

if(((Get-WmiObject win32_share | where {$_.Name -eq $CFILES -and $_.Path -eq "C:\"+$CFILES} | select Name,Path) | measure).Count -eq 1) {$tInfo[6].OK()}
if(((Get-WmiObject win32_share | where {$_.Name -eq $CPRIV+"$" -and $_.Path -eq "C:\"+$CPRIV} | select Name,Path) | measure).Count -eq 1) {$tInfo[7].OK()}

PrintPermissions($CFILES)
$rk = Read-Host -Prompt "Uprawnienia sieciowe ($CFILES)"
if($rk -gt 0) {$tInfo[9].OK()}
$rk = Read-Host -Prompt "Uprawnienia NTFS ($CFILES)"
if($rk -gt 0) {$tInfo[10].OK()}

PrintPermissions($CPRIV+"$")
$rk = Read-Host -Prompt "Uprawnienia sieciowe ($CPRIV)"
if($rk -gt 0) {$tInfo[11].OK()}
$rk = Read-Host -Prompt "Uprawnienia NTFS ($CPRIV)"
if($rk -gt 0) {$tInfo[12].OK()}

if((Get-ADComputer -filter {Name -eq $PC} | measure).Count -eq 1) {$tInfo[14].OK()}
if(((Get-ADComputer -filter {Name -eq $PC -and lastLogon -ne 0 }) | measure).Count -eq 1) {$tInfo[15].OK()}


$vgps = (Get-GPStarterGPO -Name $GPSTARTER)
$vgpo = (Get-GPO -Name $GPO)
$xmlgps = [xml]$vgps.GenerateReport("xml")
$xmlgpo = [xml]$vgpo.GenerateReport("xml")

if(($vgps | measure).Count -eq 1)
{
    $tInfo[17].OK()
    
    if(($xmlgps.Template.User.ExtensionData.Extension.Policy | where Name -like "Usuń ikonę Obrazy z menu Start").State -eq "Enabled") {$tInfo[18].OK()}
    if(($xmlgps.Template.User.ExtensionData.Extension.Policy | where Name -like "Usuń menu Pomoc z menu Start").State -eq "Enabled") {$tInfo[19].OK()}
    if(($xmlgps.Template.User.ExtensionData.Extension.Policy | where Name -like "Usuń ikonę Kosz z pulpitu").State -eq "Enabled") {$tInfo[20].OK()}    
}

if(($vgpo | measure).Count -eq 1)
{
    $tInfo[21].OK()
    if($vgpo.GpoStatus -eq "ComputerSettingsDisabled") {$tInfo[22].OK()}

    $regexp = "{[a-zA-Z0-9]{8}[-][a-zA-Z0-9]{4}[-][a-zA-Z0-9]{4}[-][a-zA-Z0-9]{4}[-][a-zA-Z0-9]{12}}" 
    $result = [Regex]::Match(((Get-ADOrganizationalUnit -Filter {Name -eq $OU}) | select -ExpandProperty LinkedGroupPolicyObjects), $regexp)
        
    if($result.Value.TrimStart("{").TrimEnd("}") -eq $vgpo.Id.Guid) {$tInfo[23].OK()}
    if(($xmlgpo.GPO.User.ExtensionData.Extension.Policy | where Name -like "Usuń ikonę Obrazy z menu Start").State -eq "Enabled") {$tInfo[24].OK()}
    if(($xmlgpo.GPO.User.ExtensionData.Extension.Policy | where Name -like "Usuń menu Pomoc z menu Start").State -eq "Enabled") {$tInfo[25].OK()}
    if(($xmlgpo.GPO.User.ExtensionData.Extension.Policy | where Name -like "Usuń ikonę Kosz z pulpitu").State -eq "Enabled") {$tInfo[26].OK()}  
    
    if(($xmlgpo.GPO.User.ExtensionData.Extension.Folder | where Id -like "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}").Location.DestinationPath -like "\\$SRVNAME\$CPRIV$\%USERNAME%\Documents") {$tInfo[27].OK()}
    if(($xmlgpo.GPO.User.ExtensionData.Extension.Folder | where Id -like "{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}").Location.DestinationPath -like "\\$SRVNAME\$CPRIV$\%USERNAME%\Start Menu") {$tInfo[28].OK()}
    if(($xmlgpo.GPO.User.ExtensionData.Extension.Policy | where Name -like "Tapeta pulpitu").EditText.Value -like "\\$SRVNAME\$CFILES\tapeta.jpg") {$tInfo[29].OK()}
    if(($xmlgpo.GPO.User.ExtensionData.Extension.Policy | where Name -like "Wyłącz element Ekran w Panelu sterowania").State -eq "Enabled") {$tInfo[30].OK()}   
}


###############################################################
# Podsumowanie

$tInfo | Select-Object @{Name="Tytuł";Expression={$_.title}}, @{Name="Waga";Expression={$_.grade}}, @{Name="Poprawnie";Expression={$_.check();}}
Write-Output ("`r`nUzyskałeś {0} / {1} punktów, co stanowi: {2,4:g4}%" -f [Info]::total, [Info]::max, (100*[Info]::total/[Info]::max))