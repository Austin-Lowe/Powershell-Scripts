####################################################################################
# Author: Austin Lowe                                                              #
####################################################################################

Import-Module sqlps

$workingDirectory = Get-Item $PWD
$fileList = Get-ChildItem $workingDirectory

#Add Database Connection String
$conn = ""

foreach( $item in $fileList)
{
    Try
    {

        Invoke-Sqlcmd -InputFile $item -ConnectionString $conn
    }
    Catch
    {
        Write-Host $item.FullName

    }
}