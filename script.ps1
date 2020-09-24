Import-Module Sharegate
Import-Module ExchangeOnlineManagement



$srcUsername = "anahita.atash-biz-yeganeh@swordcanada.onmicrosoft.com"
$srcPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force

$dstUsername = "AnaAtash@migrationlearning.onmicrosoft.com"
$dstPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force
[System.Management.Automation.PSCredential]$destinationMigrationCredentials = New-Object System.Management.Automation.PSCredential($dstUsername, $dstPassword)

    [array]$files=Get-ChildItem -path "C:\Users\aatash-biz-yeganeh\OneDrive_Migration_Folder"  |Select-Object 
     Write-Host "folders path in my pc:"
    foreach($i in $files ){
        Write-Host ($i) -ForegroundColor Green
    }
   


    Connect-PnPOnline -url "https://MigrationLearning-admin.sharepoint.com" -Credentials $destinationMigrationCredentials

    [array]$users=Get-mailbox -url "https://MigrationLearning-admin.sharepoint.com"
   
    #[array] $TenantOnedrive = Get-PnPSite   -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/" |Select-Object FullName
 

    foreach ($j in $users) {
            Write-Host ("users : "+$j) -ForegroundColor Red
    }
    
 




#instead of going throuhgh a csv file, do this below:
#go through the folder of onedrive because the username will be matched. go througgh the folder structure and for each user, get the corresponding onedrive.
#use the powereshell commands: get-item , get-shared item , get-smbShare to do so 
#PnP powershell to get file in folder, get shared folders and files on server
