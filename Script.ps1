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

[cmdletbinding()]

param (
    [Parameter (position = 0,HelpMessage = 'The users email address', Mandatory = $TRUE)]
    [String]$email,
    [Parameter (position = 1,HelpMessage = 'The users home directory', Mandatory = $TRUE)]
    [String]$homedir,
    [Parameter (position = 2,HelpMessage = 'The customers sharepoint admin site',Mandatory = $TRUE)]
    [String]$adminsite,
    [Parameter (position = 3,HelpMessage = 'The full path to the logfile',Mandatory = $TRUE)]
    [String]$logfile,
    [parameter (Position = 4,HelpMessage = 'The credential object',Mandatory = $TRUE)]
    [Object]$cred,
    [Parameter (position = 5,Mandatory = $FALSE)]
    [String]$migfolder

) 
    

   
    
Import-Module -Name Sharegate
$copysettings = New-CopySettings -OnContentItemExists IncrementalUpdate

$User = Get-OneDriveUrl -Email $email -tenant $adminsite -ProvisionIfRequired 
$rownumber++
Write-Verbose -Message "Processing $email $homedir $User" 
Add-Content $logfile -Value "Processing row $rownumber, getting the OFB-url for $email $homedir $User" 

#connect to the destination OneDrive URL
$dstSite = Connect-Site -Url $User -Credential $cred

#select destination document library, named Documents by default in OneDrive
$dstList = Get-List -Name Documents -Site $dstSite


#Copy the content from your source directory to the Documents document library in OneDrive
If ($migfolder)
{
    Import-Document -SourceFolder $migfolder -InsaneMode -DestinationList $dstList -CopySettings $copysettings -WaitForImportCompletion
    #$result = Import-Document -SourceFolder $row.HomeDirectory -DestinationList $dstList -InsaneMode -DestinationFolder 'Migrerat' -CopySettings $copysettings
    Import-Document -SourceFolder $PSitem.HomeDirectory -InsaneMode -DestinationList $dstList -DestinationFolder 'Mig' -CopySettings $copysettings
    #Export-Report $result -Path C:\MyReports\CopyContentReports.xlsx -DefaultColumns
}
Else 
{
    Import-Document -SourceFolder $PSitem.HomeDirectory -InsaneMode -DestinationList $dstList -CopySettings $copysettings
}
}