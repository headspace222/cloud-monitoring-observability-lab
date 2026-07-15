# Architecture & Design Rationale

## Why a Capstone, and Why Now

The previous five projects were each assessed and screenshotted in
isolation - each one's own portal blade, its own PowerShell session, its own
evidence set. That's a reasonable way to build and document five separate
projects, but it's not how a real environment gets operated day to day. A
platform or operations engineer wants one place to ask "did anything fail
last night," not five places. This capstone builds that one place, using
resources that already exist rather than standing up new infrastructure
purely to have something to monitor.

## Why Not Entra Sign-In Log Export

The identity governance lab already established, through direct testing
rather than assumption, that exporting Entra ID sign-in logs to Log
Analytics requires P1/P2 licensing tenant-wide - the same licensing wall
that blocked Conditional Access and PIM in that project. Re-attempting that
export here would hit the identical wall for the identical reason. This
capstone deliberately scopes around it, connecting only resource types whose
diagnostic export is genuinely free regardless of Entra ID tier: storage,
Key Vault, Automation, and Data Factory are all Azure Resource Manager
resources, a completely separate licensing domain from Entra ID premium
tiers.

## Log Analytics Free Tier: The Actual Numbers

Log Analytics workspaces include an always-free monthly data ingestion
allowance (5GB/month, per workspace, ongoing - not a time-boxed trial),
plus a limited free data retention period. This lab's five connected
resources, at their actual usage volume (a handful of test files, a handful
of runbook executions, a handful of pipeline runs), generate a trivial
fraction of that allowance. Worth stating plainly: this free allowance is
what made the identity governance lab's original plan to export sign-in logs
attractive in the first place - the ingestion was never the blocker, the
licensing prerequisite to enable export was.

## Diagnostic Settings: Different Resource Types, Different Rules

A genuine complexity worth documenting rather than glossing over: diagnostic
settings are not uniform across resource types.

- **Storage accounts** don't take a diagnostic setting directly on the
  storage account resource - blob-level logging is configured on the blob
  service sub-resource (<storageAccountId>/blobServices/default).
  Getting this wrong doesn't error clearly; it just results in an
  empty/non-functional setting, which is a worse failure mode than an
  explicit error.
- **Each resource type has its own fixed set of log categories** - Key
  Vault has essentially one (AuditEvent), Data Factory has three
  (PipelineRuns, ActivityRuns, TriggerRuns), Automation has two
  (JobLogs, JobStreams). There's no universal category list; each must
  be looked up per resource type.
- **Destination table naming depends on the diagnostic setting's
  destination type.** The "Resource specific" destination (used throughout
  this lab's KQL queries) creates purpose-named tables like ADFPipelineRun
  and AZKeyVaultAuditEvent. The older "Azure diagnostics" destination
  sends everything into a single shared AzureDiagnostics table instead,
  requiring different query filters (ResourceProvider ==, Category ==) to
  find the same data. Every KQL query in this repo notes both variants.

## Workbook: Portal-Built Primary Path, JSON as Reference

workbook/observability-workbook.json is included as a documented reference
artifact, but the setup guide's primary recommended path is building the
Workbook directly in the Azure Portal UI, adding query steps one at a time
and pasting in KQL, rather than importing the JSON via the Advanced Editor.
This mirrors a pattern repeated across this portfolio: complex, schema-heavy
artifacts proved more reliable to build through the portal's guided UI than
through direct API/JSON manipulation.

## What I'd Add at Enterprise Scale

- Alert rules wired to genuine on-call notification (email/Teams/PagerDuty
  via Action Groups), rather than a Workbook someone has to remember to check
- Cross-resource correlation - reconstructing an actual failure chain rather
  than five separate alerts
- Automated dashboard provisioning via Bicep/ARM, so the observability layer
  itself is version-controlled and reproducible
- Longer retention and a defined query-performance strategy at real scale