$Hostname = hostname
$Parameters = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters'
$TimeProvider = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer'
$Config = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config'

$server = Read-Host "Is the a server setup?(Y/N)"

#Server-side Updates
if($server -eq 'y')
{
    Write-Host "Setting up local system as NTP Server"
    Write-Host "Stopping the Time Service"
    Stop-Service -Name W32Time -Force

    if((Get-ItemProperty $Parameters).PSObject.Properties.Name -contains 'LocalNTP' -eq $false)
    {
        Write-Host "Creating LocalNTP Server RegKey"
        New-ItemProperty -Path $Parameters -Name LocalNTP -PropertyType DWORD -Value 1
    }
    Else
    {
        Write-Host "Updating LocalNTP Value"
        Set-ItemProperty -Path $Parameters -Name LocalNTP -Value 1
    }
    
    if(!(Get-ItemPropertyValue -Path $TimeProvider -Name Enabled))
    {
        Write-Host "Enabling Server Service"
        Set-ItemProperty -Path $TimeProvider -Name Enabled -Value 1
    }
    if((Get-ItemPropertyValue -Path $Config -Name AnnounceFlags) -ne 5)
    {
        Write-Host "Setting Annoucement Flags"
        Set-ItemProperty -Path $Config -Name AnnounceFlags -Value 5
    }

    Write-Host "Starting Time Service"
    Start-Service -Name W32Time
}
Else
{
    Write-Host "Setting up local system as NTP Client"
    $serverip = Read-Host "Input NTP Server Ip address: "
    $value = $serverip + ",0x9"
    Write-Host "Stopping the Time Service"
    Stop-Service -Name W32Time -Force

    Set-ItemProperty -Path $Parameters -Name NtpServer -Value $value

    Write-Host "Starting Time Service"
    Start-Service -Name W32Time
}