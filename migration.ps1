
Import-Module Sharegate
$choice = Read-Host "The migration is OneDrive to OneDrive (1) or Server to OneDrive(2)? "
$csvFile = Read-Host "Enter the file path  "

if($choice -eq "1"){
    Write-Host "OneDrive - OneDrive migration"

$table = Import-Csv $csvFile -Delimiter ","

Set-Variable srcSite, dstSite, srcList, dstList
foreach ($row in $table) {
 Clear-Variable srcSite
 Clear-Variable dstSite
 Clear-Variable srcList
 Clear-Variable dstList
 $Srcpassword =ConvertTo-SecureString $row.SourcePass -AsPlainText -Force
 $srcSite = Connect-Site -Url $row.SourceSite -Username $row.SourceUserName -Password $Srcpassword
 Add-SiteCollectionAdministrator -Site $srcSite

 $despas = ConvertTo-SecureString $row.DestinationPass -AsPlainText -Force
 $dstSite = Connect-Site -Url $row.DestinationSite -Username $row.DestinationUserName -Password $despas
 Add-SiteCollectionAdministrator -Site $dstSite
 $srcList = Get-List -Site $srcSite -Name "Documents"
 $dstList = Get-List -Site $dstSite -Name "Documents"

 

 Copy-Content -SourceList $srcList -DestinationList $dstList -DestinationFolder "Migrated Data"

 Remove-SiteCollectionAdministrator -Site $srcSite
 Remove-SiteCollectionAdministrator -Site $dstSite
}
}


if($choice -eq "2"){
    Write-Host "Server - OneDrive migration"
#$csvFile = "C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\url.csv" 
$table = Import-Csv -Path $csvFile -Delimiter ","
Set-Variable dstSite, dstList
foreach ($row in $table) {
    Clear-Variable dstSite
    Clear-Variable dstList
    $despas = ConvertTo-SecureString $row.DestinationPass -AsPlainText -Force
    $dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username $row.DestinationUserName -Password $despas
    Add-SiteCollectionAdministrator -Site $dstSite
    $dstList = Get-List -Name Documents -Site $dstSite
    
    Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList -DestinationFolder "Migrated Data"
    Remove-SiteCollectionAdministrator -Site $dstSite
}
}

