. "$PSScriptRoot\Write-Log.ps1"
$Date = (Get-Date).AddDays(-30)

Write-Log -Message "Querying AD for computers" -Severity Information
$WinComputers = Get-ADComputer -Filter * -Property * -SearchBase 'CN=Computers,DC=delphi,DC=com' | Sort-Object OperatingSystem

$TargetOU = Get-ADOrganizationalUnit -LDAPFilter "(name=Workstations)"

Write-Log -Message "Starting to move ATL computers from CN=Computers,DC=delphi,DC=com to $($TargetOU.DistinguishedName)" -Severity Information
foreach($computer in $WinComputers)
{
    if(($computer.OperatingSystem -like "Windows 10*") -and ($computer.Name.StartsWith("ATL")) -and ($computer.LastLogonDate -ge $Date))
    {
        Write-Log -Message "Moving $($computer.Name)" -Severity Information
        $computer | Move-ADObject -TargetPath $TargetOU
    }
    if(($computer.OperatingSystem -like "Windows 7*") -and ($computer.Name.StartsWith("ATL")) -and ($computer.LastLogonDate -ge $Date))
    {
        Write-Log -Message "Moving $($computer.Name)" -Severity Information
        $computer | Move-ADObject -TargetPath $TargetOU
    }
    
}