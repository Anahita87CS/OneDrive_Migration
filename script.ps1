Import-Module Sharegate
if(!(Get-Module SharePointPnPPowerShellOnline))  {
    Install-Module  SharePointPnPPowerShellOnline -Force -AllowClobber
}
# Install Azure AD if it is not already installed
if (!(Get-Module AzureAD)) {
       Install-Module  AzureAD -Force -AllowClobber
    }

#Get list of file inventory on server and write it in a .txt file
Get-ChildItem -path C:\Users\aatash-biz-yeganeh\OneDrive_Migration_Folder -recurse | Select-Object FullName,DirectoryName | Export-Csv C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\Inventory.csv -NoTypeInformation


$dstUsername = "AnaAtash@migrationlearning.onmicrosoft.com"
$dstPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force
[System.Management.Automation.PSCredential]$destinationMigrationCredentials = New-Object System.Management.Automation.PSCredential($dstUsername, $dstPassword)
$dsttenant = Connect-Site -Url "https://MigrationLearning-admin.sharepoint.com" -Username $dstUsername -Password $dstPassword
Connect-PnPOnline -url "https://MigrationLearning-admin.sharepoint.com" -Credentials $destinationMigrationCredentials

Connect-AzureAD -Credential $destinationMigrationCredentials


# Get the list of all licensed users in O365 Azure AD and create an array that holds the user's UPN
$Users = Get-AzureADUser -All $True | Where {$_.UserType -eq 'Member' -and $_.AssignedLicenses -ne $null}
$UsersArray = @()

foreach ($user in $Users) 
{
    $SPProfile  = Get-PnPUserProfileProperty -Account $user.UserPrincipalName -ErrorAction SilentlyContinue
        if ($SPProfile -ne $null)
        {
          if ($SPProfile.UserProfileProperties.AboutMe -eq "")
            {
               $UsersArray += $user
            }
        }
}

# to test if I got the correct UPN and display name of users
$UsersArray | Select-Object DisplayName, UserPrincipalName | Export-Csv -Path "C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\OneDrive_Users.csv" -NoTypeInformation

# Create OneDrive for licensed users in O365 tenant (using array of UPN we created for licensed users)
Write-Host "Creating OneDrive for licensed users  " -ForegroundColor Yellow
foreach($email in $UsersArray){    
    New-PnPPersonalSite -Email $email.UserPrincipalName    
    #Write-Host $email.UserPrincipalName -ForegroundColor Yellow  
}

Write-Host "Migration started"
#Get files on server (here, My PC for test) and put the path/URL of each folder in an array - The name of folder should match the name of OneDrive in O365
[array]$files=Get-ChildItem -path "C:\Users\aatash-biz-yeganeh\OneDrive_Migration_Folder"  

foreach($serverFileName in $files ){
   # Write-Host ("Path of files on my pc: " + $serverFileName.fullName) -ForegroundColor Gray 
   # Write-Host ("Name of the user folder on my pc: " + $serverFileName) -ForegroundColor Red
    
    foreach($OneDriveuser in $Users){
  
        Get-OneDriveUrl -Tenant $dsttenant -Email $OneDriveuser.UserPrincipalName -ProvisionIfRequired -DoNotWaitForProvisioning
        $displayNameofOneDrive = Get-PnPUserProfileProperty -Account $OneDriveuser.UserPrincipalName
      
       if($displayNameofOneDrive.DisplayName -eq $serverFileName ){
            Write-Host ("URL.DisplayName: " + $displayNameofOneDrive.DisplayName + " =  serverFileName: " +$serverFileName) -ForegroundColor Green
            
            $dstSite = Connect-Site -Url $displayNameofOneDrive.PersonalUrl  -Username $dstUsername -Password $dstPassword
      
            Write-Host ("Destination site :    "+$dstSite) -ForegroundColor Red -BackgroundColor Yellow
        
            Add-SiteCollectionAdministrator -Site $dstSite

            $dstList = Get-List -Name Documents -Site $dstSite
            Import-Document -SourceFolder $serverFileName.fullName -DestinationList $dstList 
            Remove-SiteCollectionAdministrator -Site $dstSite
        }
       
       
        
    }

}