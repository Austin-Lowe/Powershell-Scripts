if($args[0] -eq '-setup')
{
    $Drives = Get-WmiObject win32_Volume -Filter ("DriveType={0}" -f [int][System.IO.DriveType]::Removable)

    Copy-Item -Path .\TouchScreenCalibration.ps1 -Destination C:\RVCT\tools

    foreach($Drive in $Drives)
    {
        if($Drive.Label -eq 'KIT')
        {
            $Path = $Drive.DriveLetter + '\TouchscreenCalibration.reg'
            if (Test-Path $Path)
            {
                Remove-Item $Path
            }

            Invoke-Command {reg export 'HKLM\SOFTWARE\Microsoft\Wisp\Pen\Digimon' $Path } -ErrorVariable errmsg 2>$null

            $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument 'C:\RVCT\Tools\TouchScreenCalibration.ps1'
            $trigger = New-ScheduledTaskTrigger -AtLogOn
            $trigger.Delay = 'PT20S'
            $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
            $settings = New-ScheduledTaskSettingsSet
            $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
            Register-ScheduledTask "Touchscreen Calibration" -InputObject $task
        }
    }
}

else
{
    $Drive = Get-WmiObject win32_Volume -Filter ("DriveType={0}" -f [int][System.IO.DriveType]::Removable)
    foreach($Drive in $Drives)
    {
        if($Drive.label -eq 'KIT')
        {
            $Path = $Drive.DriveLetter + '\TouchscreenCalibration.reg'
            if(Test-Path $Path)
            {
                $OldKeys = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Wisp\Pen\Digimon'

                if($OldKeys -ne $null)
                {
                    Remove-Item $OldKeys.PSPath
                }

                Invoke-Command {reg import $Path } -ErrorVariable errmsg 2>$null

                Stop-Process -Name dwm -Force
            }
        }
    }
}