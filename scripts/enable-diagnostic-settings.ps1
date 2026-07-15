<#
.SYNOPSIS
    Enables diagnostic settings on storage, Key Vault, Automation Account,
    and Data Factory resources, sending their logs to the shared Log
    Analytics workspace.

.PARAMETER WorkspaceResourceId
    Full Resource ID of the target Log Analytics workspace.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceResourceId,

    [string]$MigrationStorageAccountRG,
    [string]$MigrationStorageAccountName,

    [string]$BatchStorageAccountRG,
    [string]$BatchStorageAccountName,

    [string]$KeyVaultRG,
    [string]$KeyVaultName,

    [string]$AutomationAccountRG,
    [string]$AutomationAccountName,

    [string]$DataFactoryRG,
    [string]$DataFactoryName
)

$results = @()

function Enable-DiagSetting {
    param($ResourceId, $SettingName, $Categories, $Description)

    try {
        $logSettings = $Categories | ForEach-Object {
            New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_
        }
        New-AzDiagnosticSetting -ResourceId $ResourceId -Name $SettingName -WorkspaceId $WorkspaceResourceId -Log $logSettings -ErrorAction Stop | Out-Null
        Write-Host "  [OK] $Description" -ForegroundColor Green
        return [PSCustomObject]@{ Resource = $Description; Status = "Success"; Detail = "" }
    } catch {
        Write-Host "  [FAILED] $Description - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    If this is a parameter/cmdlet error, configure this one manually via Portal: resource -> Diagnostic settings -> Add diagnostic setting." -ForegroundColor Yellow
        return [PSCustomObject]@{ Resource = $Description; Status = "Failed"; Detail = $_.Exception.Message }
    }
}

if ($MigrationStorageAccountName) {
    Write-Host "`nStorage (migration lab): $MigrationStorageAccountName ..." -ForegroundColor Cyan
    $sa = Get-AzStorageAccount -ResourceGroupName $MigrationStorageAccountRG -Name $MigrationStorageAccountName
    $blobServiceId = "$($sa.Id)/blobServices/default"
    $results += Enable-DiagSetting -ResourceId $blobServiceId -SettingName "diag-to-observability-workspace" -Categories @("StorageRead", "StorageWrite", "StorageDelete") -Description "Migration lab storage ($MigrationStorageAccountName) blob logs"
}

if ($BatchStorageAccountName) {
    Write-Host "`nStorage (batch/streaming lab): $BatchStorageAccountName ..." -ForegroundColor Cyan
    $sa = Get-AzStorageAccount -ResourceGroupName $BatchStorageAccountRG -Name $BatchStorageAccountName
    $blobServiceId = "$($sa.Id)/blobServices/default"
    $results += Enable-DiagSetting -ResourceId $blobServiceId -SettingName "diag-to-observability-workspace" -Categories @("StorageRead", "StorageWrite", "StorageDelete") -Description "Batch lab storage ($BatchStorageAccountName) blob logs"
}

if ($KeyVaultName) {
    Write-Host "`nKey Vault: $KeyVaultName ..." -ForegroundColor Cyan
    $kv = Get-AzKeyVault -ResourceGroupName $KeyVaultRG -VaultName $KeyVaultName
    $results += Enable-DiagSetting -ResourceId $kv.ResourceId -SettingName "diag-to-observability-workspace" -Categories @("AuditEvent") -Description "Key Vault ($KeyVaultName) audit events"
}

if ($AutomationAccountName) {
    Write-Host "`nAutomation Account: $AutomationAccountName ..." -ForegroundColor Cyan
    $aa = Get-AzAutomationAccount -ResourceGroupName $AutomationAccountRG -Name $AutomationAccountName
    $aaResourceId = "/subscriptions/$($aa.SubscriptionId)/resourceGroups/$($aa.ResourceGroupName)/providers/Microsoft.Automation/automationAccounts/$($aa.AutomationAccountName)"
    $results += Enable-DiagSetting -ResourceId $aaResourceId -SettingName "diag-to-observability-workspace" -Categories @("JobLogs", "JobStreams") -Description "Automation Account ($AutomationAccountName) job logs"
}

if ($DataFactoryName) {
    Write-Host "`nData Factory: $DataFactoryName ..." -ForegroundColor Cyan
    $adfResourceId = "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/$DataFactoryRG/providers/Microsoft.DataFactory/factories/$DataFactoryName"
    $results += Enable-DiagSetting -ResourceId $adfResourceId -SettingName "diag-to-observability-workspace" -Categories @("PipelineRuns", "ActivityRuns", "TriggerRuns") -Description "Data Factory ($DataFactoryName) run history"
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

Write-Host "`nNote: newly configured diagnostic settings can take 15-30 minutes to start" -ForegroundColor Yellow
Write-Host "flowing data into the workspace, and log data itself is only captured for" -ForegroundColor Yellow
Write-Host "events occurring after the setting was enabled - nothing retroactive." -ForegroundColor Yellow