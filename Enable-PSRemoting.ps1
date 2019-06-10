$computers = Import-Csv -Path C:\Users\Austin.Lowe\Documents\Scripts\Powershell\report-last_login_2019_03_18.csv

foreach($computer in $computers)
{
    if($computer.'Last Login' -ne "")
    {
        if($computer.Name -like 'atl*')
        {
            Write-Host $computer.Name
            Start-Process -FilePath C:\PSTools\PsExec.exe -ArgumentList "\\$($computer.Name) -s powershell Enable-PSRemoting -Force" -Wait
        }
    }
}
