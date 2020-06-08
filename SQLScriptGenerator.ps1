####################################################################################
# Author: Austin Lowe                                                              #
####################################################################################
# add the following line to your $PROFILE
#Set-Alias tf "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"

Import-Module sqlps
tf get ./ /overwrite
$formattedDate = Get-Date -UFormat "%Y%m%d"
$workingDirectory = Get-Item $PWD
$versionCheck = Get-ChildItem | Where-Object {($_.Name -like '0000*')}
$versionUpdate = Get-ChildItem | Where-Object {($_.Name -like 'xxxx*') -or ($_.Name -like 'zzzz*')}
$newReleaseDir = ($workingDirectory.Parent.FullName +'\' + ([double]$workingDirectory.Name + .001))
$newversionUpdate = $newReleaseDir + '\' + $versionUpdate.Name
$newversionCheck =  $newReleaseDir + '\' + $versionCheck.Name
$versionName = Read-Host -Prompt 'Input Client Schema'
$conn = Read-Host -Prompt 'Input Connectionstring to Testing Database'


#Need to put logic for handling "(Azure)" in the filename
#Done
$filename = $versionName + "_" + $workingDirectory.Name + "_UpdateScript" + "_$formattedDate" + ".sql" -replace '(Azure)', ''

$file = $workingDirectory.FullName + "\_Released_$formattedDate\"  + $filename
$fileExist = Test-Path ($workingDirectory.FullName + "\_Released_$formattedDate\"  + $filename)

If($fileExist -eq $False)
{
    New-Item -ItemType Directory -Force -Path ($workingDirectory.FullName + "\_Released_$formattedDate\")
    New-Item -Name $filename -Path ($workingDirectory.FullName + "\_Released_$formattedDate\")

    #Build next Release folder
    New-Item -ItemType Directory -Force -Path $newReleaseDir
    (Get-Content -Path $versionCheck -Raw) -replace ([double]$workingDirectory.Name - .001) , $workingDirectory.Name | Set-Content -Path $newversionCheck -Force
    (Get-Content -Path $versionUpdate -Raw) -replace $workingDirectory.Name, ([double]$workingDirectory.Name + .001) | Set-Content -Path $newversionUpdate -Force
    
}

$fileList = Get-ChildItem $workingDirectory

$permissions = "IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE NAME = 'spCfgGrantPermissions')`r`nBEGIN`r`n"

foreach($item in $fileList)
{
    if($item.Extension -eq ".sql" -and $item.Name -ne $filename)
    {
        Add-Content -Path $file -Value "`r`nGO`r`n"
        Add-Content -Path $file -Value "print 'Executing $item'`r`nGO`r`n"
        $data = Get-Content $item
        Add-Content -Path $file -Value $data
        Add-Content -Path $file -Value "`r`nGO`r`n"
        $permissions = $permissions + "`tExec spCfgGrantPermissions '$item'`r`n"

    }

}

$permissions = $permissions + "END`r`nGO"
Add-Content -Path $file -Value $permissions

try {
    Invoke-Sqlcmd -InputFile $file -ConnectionString $conn -QueryTimeout 65535 -ErrorAction Stop
} catch {
  Write-HOST "`nScript Test Output`n"
  Write-Host($_)
}

$ans = Read-Host -Prompt "`nCommit to TFS? (Y/N)"
If($ans -eq 'Y' -or $ans -eq 'y')
{
    tf add $newversionUpdate $newversionCheck $file
    tf checkin $newversionUpdate $newversionCheck $file /comment:"Building Release" /override:"Building Release"
}

