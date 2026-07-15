# Setup Guide

Connects resources from four earlier projects into one shared observability
layer. Replace resource names below with your actual ones if they differ.

**Estimated time:** 60-75 minutes, including propagation waits.

## Step 1 - Create the Shared Workspace

```powershell
cd C:\cloud-monitoring-observability-lab
.\scripts\create-log-analytics-workspace.ps1 -ResourceGroupName "rg-monitoring-lab" -WorkspaceName "law-observability-jane01" -Location "uksouth"
```

Copy the printed Workspace Resource ID.

**Evidence to capture:**
- 01-workspace-created.png

## Step 2 - Wire In Diagnostic Settings

```powershell
.\scripts\enable-diagnostic-settings.ps1 -WorkspaceResourceId "<paste-workspace-resource-id>" -MigrationStorageAccountRG "rg-data-migration-lab" -MigrationStorageAccountName "stmigrationlabjane01" -BatchStorageAccountRG "rg-batch-streaming-lab" -BatchStorageAccountName "stbatchstreamjane01" -KeyVaultRG "rg-security-posture-lab" -KeyVaultName "kv-secpostlab-jane01" -AutomationAccountRG "rg-cost-governance-lab" -AutomationAccountName "aa-cost-governance-lab" -DataFactoryRG "rg-batch-streaming-lab" -DataFactoryName "<your-actual-adf-name>"
```

**Evidence to capture:**
- 02-diagnostic-settings-summary.png
- 03-diagnostic-setting-portal-view.png

## Step 3 - Wait for Data to Flow

Wait 20-30 minutes after Step 2 before querying. Generate fresh activity in
the meantime (upload/delete a file, run a runbook, trigger the pipeline).

## Step 4 - Run the KQL Queries

Portal, Log Analytics workspace, Logs. Run each query in kql-queries/.

**Evidence to capture:**
- 04-kql-query-results.png

## Step 5 - Build the Workbook

1. Portal, Workbooks, + New
2. Edit, + Add, Add query
3. Paste a KQL query, select your workspace, choose a visualization
4. Repeat for 2-3 more queries
5. Save

**Evidence to capture:**
- 05-workbook-dashboard.png

## Step 6 - (Optional) One Alert Rule

Small non-zero cost, same caveat as elsewhere in this portfolio.

**Evidence to capture (optional):**
- 06-alert-rule-configured.png

## Step 7 - Push

```powershell
cd C:\cloud-monitoring-observability-lab
git init
git add -A
git commit -m "Initial build: shared observability workspace across four portfolio projects"
git branch -M main
git remote add origin https://github.com/headspace222/cloud-monitoring-observability-lab.git
git push -u origin main
```