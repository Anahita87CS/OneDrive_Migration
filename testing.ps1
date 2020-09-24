$dstUsername = "anahita.atash-biz-yeganeh@swordcanada.onmicrosoft.com"
$dstPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force
[System.Management.Automation.PSCredential]$destinationMigrationCredentials = New-Object System.Management.Automation.PSCredential($dstUsername, $dstPassword)

Connect-PnPOnline -url "https://swordcanada-admin.sharepoint.com" -Credentials $destinationMigrationCredentials

Get-PnPUser  |Select-Object Title,Email | Export-Csv C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\swordcanada.csv 
