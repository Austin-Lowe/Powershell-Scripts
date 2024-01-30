$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-WindowStyle hidden C:\RVCT\Monitor.ps1'
$trigger = New-ScheduledTaskTrigger -AtLogOn
$trigger.Delay = 'PT20S'
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask "Monitor" -InputObject $task