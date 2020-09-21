Import-Module Sharegate

$srcUsername = "anahita.atash-biz-yeganeh@swordcanada.onmicrosoft.com"
$srcPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force

$dstUsername = "AnaAtash@migrationlearning.onmicrosoft.com"
$dstPassword = ConvertTo-SecureString "Annakjkj@75" -AsPlainText -Force

$Sourcetenant = Connect-Site -Url "https://swordcanada-admin.sharepoint.com" -Username $srcUsername -Password $srcPassword
$SourceFile = "C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\urlSwordCanada.csv"
$table = Import-Csv $SourceFile -Delimiter ","
foreach ($row in $table) {
    Get-OneDriveUrl -Tenant $Sourcetenant -Email $row.Email -ProvisionIfRequired -DoNotWaitForProvisioning
}

$dsttenant = Connect-Site -Url "https://MigrationLearning-admin.sharepoint.com" -Username $dstUsername -Password $dstPassword
$DestinationFile = "C:\Users\aatash-biz-yeganeh\oneDriveTest-ShareGate\urlMigrationLearning.csv"
$table = Import-Csv $DestinationFile -Delimiter ","
foreach ($row in $table) {
    Get-OneDriveUrl -Tenant $dsttenant -Email $row.Email -ProvisionIfRequired -DoNotWaitForProvisioning
}
