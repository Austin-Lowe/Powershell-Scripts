$SystemInfo = Get-CimInstance -ClassName Win32_Bios
$NewName = "ATL-" + $SystemInfo.SerialNumber
$creds = Get-Credential Delphi\Austin.Lowe
Rename-Computer -NewName $NewName -Force

$Bloatware = @(
        #Unnecessary Windows 10 AppX Apps
        "Microsoft.BingNews"
        "Microsoft.DesktopAppInstaller"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.RemoteDesktop"
        "Microsoft.SkypeApp"
        "Microsoft.StorePurchaseApp"
        "Microsoft.WindowsAlarms"
        #"Microsoft.WindowsCamera"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
             
        #Sponsored Windows 10 AppX Apps
        #Add sponsored/featured apps to remove in the "*AppName*" format
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Spotify*"
        "*Minecraft*"
        "*Royal Revolt*"
        )

New-PSDrive -Name Apps -PSProvider FileSystem -Root "\\ATL-ALOWE-DTHP6300\DeploymentShare$\Applications" -Credential $creds

Start-Process "Apps:\Microsoft Office 2013 x64\setup.exe" -ArgumentList "/adminfile .\DefaultConfig_12042018.MSP" -Wait

Start-Process 'Apps:\Pandion 2.6.114\Pandion_2.6.114.msi' -ArgumentList "/qn" -Wait

Start-Process 'Apps:\Adobe Acrobat Reader DC 19.008200.81\AcroRead.msi' -ArgumentList "/qn TRANSFORM=AcroRead.mst" -Wait

Start-Process 'Apps:\Cisco Anyconnect\anyconnect-win-4.3.02039-pre-deploy-k9.msi' -ArgumentList "/qn" -Wait
Copy-Item -Path $PSScriptRoot\cisco -Destination 'C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile' -Force

Start-Process 'Apps:\Igor Pavlov 7-Zip 18.05\7z1805-x64.msi' -ArgumentList "/qn" -Wait

Start-Process 'Apps:\Google Chrome\ChromeStandaloneSetup64.exe' -ArgumentList "/silent /install" -Wait

Start-Process 'Apps:\OCS Inventory Agent 2.1.1.1\OCS-NG-Windows-Agent-Setup.exe' -ArgumentList "/S /NOSPLASH /SERVER=http://ocs.Contoso.com/ocsinventory" -Wait

Remove-PSDrive -Name Apps -Force

foreach ($Bloat in $Bloatware) 
{

        Get-AppxPackage -Name $Bloat| Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Debloat | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Output "Trying to remove $Bloat."
}

$IACPrompt = Read-Host -Prompt "Do you want to install IAC Settings? (y/n)"
if(($IACPrompt -eq "y") -or ($IACPrompt -eq "Y"))
{
    Rename-Item -Path C:\Windows\System32\drivers\etc\hosts -NewName "OLDhosts" -Force
    Copy-Item -Path $PSScriptRoot\iac\hosts -Destination C:\Windows\System32\drivers\etc -Force\

    Copy-Item -Path $PSScriptRoot\iac -Destination C:\Users\Default\Desktop -Force
    
}

Start-Sleep -Seconds 15

Add-Computer -DomainName delphi.com -OUPath "OU=Workstations,OU=ContosoAtlanta,DC=delphi,DC=com" -Credential $creds -Force -Restart