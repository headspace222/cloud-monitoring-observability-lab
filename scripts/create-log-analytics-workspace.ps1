<#
.SYNOPSIS
    Creates the shared Log Analytics workspace this capstone's diagnostic
    settings all send data to.

.PARAMETER ResourceGroupName
    Resource group for the workspace.

.PARAMETER WorkspaceName
    Name of the Log Analytics workspace.

.PARAMETER Location
    Azure region for the workspace.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$WorkspaceName,

    [string]$Location = "uksouth"
)

Write-Host "Creating resource group (if it doesn't already exist) ..." -ForegroundColor Cyan
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag @{CostCenter="LAB001"; Owner="jane"; Environment="NonProduction"} -Force | Out-Null

Write-Host "Creating Log Analytics workspace '$WorkspaceName' ..." -ForegroundColor Cyan
New-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -Location $Location -Sku "PerGB2018" -Tag @{CostCenter="LAB001"; Owner="jane"; Environment="NonProduction"}

Write-Host "`nVerifying ..." -ForegroundColor Green
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
$workspace | Select-Object Name, Location, Sku, ProvisioningState

Write-Host "`nWorkspace Resource ID (needed for the next script):" -ForegroundColor Cyan
Write-Host $workspace.ResourceId -ForegroundColor Yellow