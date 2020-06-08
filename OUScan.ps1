
$OU = "OU=Labs,OU=Classrooms and Labs,OU=Contoso,OU=Departmental OUs,DC=net,DC=Contoso,DC=com"

$AdminUserName = "net\admin"
$AdminPassword = "C:\project\admin.key"

$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminUserName, (Get-Content $AdminPassword | ConvertTo-SecureString)

$Computers = Get-ADComputer -Filter * -SearchBase $OU

ForEach($computer in $Computers)
{
    Invoke-Command -ComputerName $computer.Name -Credential $creds -ErrorAction SilentlyContinue -ScriptBlock{
    
        $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'" | Select-Object Size,FreeSpace
        if([Math]::Round($disk.FreeSpace/1GB) -lt 20)
        {
            Write-host "$env:COMPUTERNAME C: has $([Math]::Round($disk.FreeSpace/1GB)) GB free of $([Math]::Round($disk.Size/1GB)) GB Total"
            
            $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
            $Cache = $UIResourceMgr.GetCacheInfo()
            $CacheElements = $Cache.GetCacheElements()

            foreach($Element in $CacheElements)
            {
                $Cache.DeleteCacheElement($Element.CacheElementId)
            }
        }
    }  
}