####################################################################################
# Author: Austin Lowe                                                              #
####################################################################################

Add-Type -AssemblyName System.Windows.Forms

$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.Description = "Please Select Published App Directory"

$Topmost = New-Object System.Windows.Forms.Form
$Topmost.TopMost = $True
$Topmost.MinimizeBox = $True

[void]$FolderBrowser.ShowDialog($Topmost)
$FolderBrowser.SelectedPath

$serviceHostDir = $FolderBrowser.SelectedPath + "\ServiceHost\bin"
$webUIDir = $FolderBrowser.SelectedPath + "\WebUI\bin"

if([string]::IsNullOrEmpty($FolderBrowser.SelectedPath) -eq $False)
{
    $formattedDate = Get-Date -UFormat "%Y%m%d"
    $workingDirectory = Get-Item $PWD

    If(Test-Path -Path ($workingDirectory.FullName + "\$formattedDate"))
    {
        Remove-Item -Path ($workingDirectory.FullName + "\$formattedDate") -Recurse -Forcecd
    }

    #Create Directories
    New-Item -ItemType Directory -Force -Path ($workingDirectory.FullName + "\$formattedDate\Codebase\wwwroot\bin") | Out-Null
    New-Item -ItemType Directory -Force -Path ($workingDirectory.FullName + "\$formattedDate\Codebase\wwwroot\Service\bin") | Out-Null
    New-Item -ItemType Directory -Force -Path ($workingDirectory.FullName + "\$formattedDate\Database") | Out-Null

    #Copy WebUI Files
    $webUIFiles = Get-ChildItem -Path $webUIDir -Exclude "*.config" | Where-Object { ($_.LastWriteTime -gt (Get-Date).AddDays(-1))-and ($_.Attributes -ne 'Directory')}
    Copy-Item -Path $webUIFiles -Destination ($workingDirectory.FullName + "\$formattedDate\Codebase\wwwroot\bin")


    If((Test-Path -Path $serviceHostDir) -eq $false)
    {
        $msgInput = [System.Windows.Forms.MessageBox]::Show("No ServiceHost Directory Found`n`nWould you like to point to another directory?",'ServiceHost Not Found', 'YesNoCancel', 'Warning')

        if($msgInput -eq 'YES')
        {
            [void]$FolderBrowser.ShowDialog($Topmost)
            $serviceHostDir = $FolderBrowser.SelectedPath + "\ServiceHost\bin"

        }

    }
    
    $serviceHostFiles = Get-ChildItem -Path $serviceHostDir -Exclude "*.config" | Where-Object { ($_.LastWriteTime -gt (Get-Date).AddDays(-1)) -and ($_.Name -notlike '*.config') -and ($_.Attributes -ne 'Directory')}
    Copy-Item -Path $serviceHostFiles -Destination ($workingDirectory.FullName + "\$formattedDate\Codebase\wwwroot\Service\bin")

    if($webUIFiles.Count -notin 12,16 -or $serviceHostFiles.Count -notin 6,12)
    {
        [System.Windows.Forms.MessageBox]::Show("Insufficent File Count!",'Insufficent File Count', 'OK', 'Error') | Out-Null

    }

}
else
{
    [System.Windows.Forms.MessageBox]::Show("No Directory Selected!",'Directory Not Selected', 'OK', 'Error')
}