<#
$tenant = Connect-Site -Url "https://swordcanada-admin.sharepoint.com" -Browser
$csvFile = "C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\url.csv"
$table = Import-Csv $csvFile -Delimiter ","
foreach ($row in $table) {
    Get-OneDriveUrl -Tenant $tenant -Email $row.Email -ProvisionIfRequired -DoNotWaitForProvisioning
}


Write-Host "step 1"
$mypassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force
$tenant = Connect-Site -Url "https://swordcanada-admin.sharepoint.com" -Username "anahita.atash-biz-yeganeh@swordcanada.onmicrosoft.com" -Password $mypassword
Get-OneDriveUrl -Tenant $tenant -Email anahita.atash-biz-yeganeh@swordcanada.onmicrosoft.com -ProvisionIfRequired -DoNotWaitForProvisioning
#>

param (
    
    [Parameter(Position=0,mandatory=$true)]
    [string]$type,
    [Parameter(Position=1,mandatory=$true)]
    [string]$csvFile

   
)
 
Import-Module Sharegate

if($type.ToUpper() -eq "ONEDRIVE"){
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

 if(! $srcList){
     Write-Host ("The source list " +$srcList+ " does not exist") 

 }
 else{

 Copy-Content -SourceList $srcList -DestinationList $dstList -DestinationFolder "Migrated Data"
}
 Remove-SiteCollectionAdministrator -Site $srcSite
 Remove-SiteCollectionAdministrator -Site $dstSite
}
}


if($type.ToUpper() -eq "SERVER"){
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
    #Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList
    Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList -DestinationFolder "Migrated Data"
    Remove-SiteCollectionAdministrator -Site $dstSite
}
}

