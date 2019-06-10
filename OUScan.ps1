#$OU = "OU=HPH-311J,OU=Classrooms and Labs,OU=College of Sciences,OU=Departmental OUs,DC=net,DC=ucf,DC=edu"
#$OU = "OU=Desktops,OU=MSB-418 GTA Workroom,OU=Departments,OU=College of Sciences,OU=Departmental OUs,DC=net,DC=ucf,DC=edu"
#$OU = "OU=Windows 10 Office Desktops,OU=Office of Instructional Resources,OU=Departmental OUs,DC=net,DC=ucf,DC=edu"
$OU = "OU=Physics Studio Labs,OU=Classrooms and Labs,OU=College of Sciences,OU=Departmental OUs,DC=net,DC=ucf,DC=edu"
#$OU = "OU=NetSupport Instructor Computers,OU=Classroom Consoles,OU=Console Computers,OU=Classrooms and Labs,OU=College of Sciences,OU=Departmental OUs,DC=net,DC=ucf,DC=edu"
#$OU = "OU=Classrooms and Labs,OU=College of Sciences,OU=Departmental OUs,DC=net,DC=ucf,DC=edu"
#$OU = "OU=Desktops, OU=Global Perspectives CHEM-117 Office, OU=Departments, OU=College of Sciences, OU=Departmental OUs, DC=net, DC=ucf, DC=edu"
#$OU = "OU=Desktops,OU=Psychology,OU=Departments,OU=College of Sciences,OU=Departmental OUs,DC=net,DC=ucf,DC=edu"
$NidAdminUserName = "net\au965898admin"
$NidAdminPassword = "C:\project\au965898admin.key"

$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $NidAdminUserName, (Get-Content $NidAdminPassword | ConvertTo-SecureString)

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