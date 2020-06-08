#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '7/3/2017 12:33:14 PM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "U05:" # Set the current location to be the site code.

$ComputerList = Import-Csv -Path C:\SCCMDSL\WindowsUpgrade.csv

$LimitingCollection = Get-CMDeviceCollection -Name "Contoso"
$DestinationCollection = Get-CMDeviceCollection -Name "Windows 10 Upgrade"
$PostUpgradeCollection = Get-CMDeviceCollection -Name "Post Windows 10"

$outputCSV = @()

foreach($item in $ComputerList)
{
   $Device = Get-CMDevice -Name $item.Name.ToString() -Collection $LimitingCollection

   if($Device.DeviceOS -eq "Microsoft Windows NT Workstation 10.0")
   {
        if($PostUpgradeCollection.CollectionRules | Where-Object { $_.RuleName -eq $Device.Name})
        {
            Write-Host $Device.Name "is in post Windows 10"

        }
        else
        {
            Write-Host $Device.Name "will be moved to Post Windows 10 Upgrade"
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionId $DestinationCollection.CollectionID -ResourceId $Device.ResourceID -Force
            Add-CMDeviceCollectionDirectMembershipRule -CollectionId $PostUpgradeCollection.CollectionID -ResourceId $Device.ResourceID
        
        }
   }

   elseif($Device.DeviceOS -eq "Microsoft Windows NT Workstation 6.1")
   {
        if($PostUpgradeCollection.CollectionRules | Where-Object { $_.RuleName -eq $Device.Name})
        {
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionId $PostUpgradeCollection.CollectionID -ResourceId $Device.ResourceID -Force

        }

        elseif($DestinationCollection.CollectionRules | Where-Object { $_.RuleName -eq $Device.Name})
        {
            Write-Host $Device.Name "has not been migrated"
        }

        else
        {
            Write-Host $Device.Name "will be added to the migration"
            Add-CMDeviceCollectionDirectMembershipRule -CollectionId $DestinationCollection.CollectionID -ResourceId $Device.ResourceID    
        }
   }

   elseif($null -eq $Device.Name)
   {
        Write-Host $item.ROOM
   
   }

   $outputCSV += New-Object psobject -Property @{ 
   'ROOM' = $item.ROOM
   'Name' = $Device.Name
   'Model' = $item.Model
   'OS' = $Device.DeviceOS
   'Other' = $item.Other
   }

}

$outputCSV | Select-Object -Property ROOM,Name,Model,OS,Other | Export-Csv -Path $PSScriptRoot\Windows10Output.csv