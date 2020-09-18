param (
    
    [Parameter(Position=0,mandatory=$false)]
    [string]$type,
    [Parameter(Position=1,mandatory=$true)]
    [string]$csvFile

   
)
Import-Module Sharegate

$table = Import-Csv $csvFile -Delimiter ","

$srcUsername = "anahita.atash-biz-yeganeh@swordcanada.onmicrosoft.com"
$srcPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force

$dstUsername = "AnaAtash@migrationlearning.onmicrosoft.com"
$dstPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force

Set-Variable srcSite, dstSite, srcList, dstList
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