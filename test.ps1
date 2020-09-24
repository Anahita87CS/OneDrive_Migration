Import-Module Sharegate

$choice = Read-Host "The migration is OneDrive to OneDrive (1) or Server to OneDrive(2)? "
$csvFile = Read-Host "Enter the file path  "

$srcUsername = "anahita.atash-biz-yeganeh@swordcanada.onmicrosoft.com"
$srcPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force

$dstUsername = "AnaAtash@migrationlearning.onmicrosoft.com"
$dstPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force

Set-Variable srcSite, dstSite, srcList, dstList
if($choice -eq "1"){
    Write-Host "OneDrive - OneDrive migration"
    $table = Import-Csv $csvFile -Delimiter ","
foreach ($row in $table) {
    Clear-Variable srcSite
    Clear-Variable dstSite
    Clear-Variable srcList
    Clear-Variable dstList
    $srcSite = Connect-Site -Url $row.SourceSite -Username $srcUsername -Password $srcPassword
    Add-SiteCollectionAdministrator -Site $srcSite
    $dstSite = Connect-Site -Url $row.DestinationSite -Username $dstUsername -Password $dstPassword
    Add-SiteCollectionAdministrator -Site $dstSite
    $srcList = Get-List -Site $srcSite -Name "Documents"
    $dstList = Get-List -Site $dstSite -Name "Documents"
    
    Copy-Content -SourceList $srcList -DestinationList $dstList -DestinationFolder "Migrated Data"
    Remove-SiteCollectionAdministrator -Site $srcSite
    Remove-SiteCollectionAdministrator -Site $dstSite
}
}

if($choice -eq "2"){
    Write-Host "Server (my PC for now) - OneDrive migration"
#$csvFile = "C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\url.csv" 
$table = Import-Csv -Path $csvFile -Delimiter ","
Set-Variable dstSite, dstList
foreach ($row in $table) {
    Clear-Variable dstSite
    Clear-Variable dstList
   
    $dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username $dstUsername -Password $dstPassword
    Add-SiteCollectionAdministrator -Site $dstSite
    $dstList = Get-List -Name Documents -Site $dstSite
    #Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList
    Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList -DestinationFolder "Migrated Data"
    Remove-SiteCollectionAdministrator -Site $dstSite
}
}

#instead of going throuhgh a csv file, do this below:
#go through the folder of onedrive because the username will be matched. go througgh the folder structure and for each user, get the corresponding onedrive.
#use the powereshell commands: get-item , get-shared item to do so 
