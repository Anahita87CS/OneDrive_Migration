<#
$tenant = Connect-Site -Url "https://swordcanada-admin.sharepoint.com" -Browser
$File = "C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\url.csv"
$table = Import-Csv $File -Delimiter ","
foreach ($row in $table) {
    Get-OneDriveUrl -Tenant $tenant -Email $row.Email -ProvisionIfRequired -DoNotWaitForProvisioning
}



#>

param (
    
    [Parameter(Position=0,mandatory=$true)]
    [string]$type,
    [Parameter(Position=1,mandatory=$true)]
    [string]$csvFile

   
)
 
Import-Module Sharegate
$table = Import-Csv $csvFile -Delimiter ","
if($type.ToUpper() -eq "ONEDRIVE"){
    Write-Host "OneDrive - OneDrive migration"

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
 if(!$srcList){
     Write-Host ("The source list " +$srcList+ " does not exist") 
 }
 else{
 Copy-Content -SourceList $srcList -DestinationList $dstList
}
 Remove-SiteCollectionAdministrator -Site $srcSite
 Remove-SiteCollectionAdministrator -Site $dstSite
}
}

if($type -eq "Server"){
    Write-Host "Server - OneDrive migration"
Set-Variable dstSite, dstList
foreach ($row in $table) {
    Clear-Variable dstSite
    Clear-Variable dstList
    $despas = ConvertTo-SecureString $row.DestinationPass -AsPlainText -Force
    $dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username $row.DestinationUserName -Password $despas
    Add-SiteCollectionAdministrator -Site $dstSite
    $dstList = Get-List -Name Documents -Site $dstSite
    Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList
    Remove-SiteCollectionAdministrator -Site $dstSite
}
}

