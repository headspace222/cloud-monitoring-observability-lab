# Monitoring & Observability Capstone

**A unified Log Analytics workspace and Azure Monitor Workbook pulling
telemetry from resources across four earlier projects in this portfolio -
built entirely on free-tier Azure capabilities.**

Every project in this portfolio so far has been assessed one resource at a
time, in its own portal blade. That's not how a real environment gets
monitored day to day - a platform or operations team wants one place to ask
"what failed across my environment today," not five separate places. This
capstone builds that one place: a shared Log Analytics workspace collecting
diagnostic data from storage, Key Vault, Azure Automation, and Data Factory
resources already built earlier in this portfolio, queried through a small
library of KQL and visualised in a single Workbook.

## What This Deliberately Does Not Include

**Entra ID sign-in log export** is not part of this capstone. The identity
governance lab already established - and confirmed via direct testing, not
assumption - that exporting Entra sign-in logs to Log Analytics requires
P1/P2 licensing tenant-wide. Re-attempting that here would just hit the same
wall for the same reason. This capstone respects that earlier finding rather
than re-litigating it, and stays entirely within resource types whose
diagnostic logs are genuinely free to export at this lab's data volume.

## What's Included

| Component | Purpose |
|---|---|
| [`scripts/create-log-analytics-workspace.ps1`](scripts/create-log-analytics-workspace.ps1) | Creates the shared workspace all other resources send data to |
| [`scripts/enable-diagnostic-settings.ps1`](scripts/enable-diagnostic-settings.ps1) | Wires storage, Key Vault, Automation Account, and Data Factory into the shared workspace |
| [`kql-queries/`](kql-queries/) | A small library of KQL answering real operational questions across all connected resources |
| [`workbook/observability-workbook.json`](workbook/observability-workbook.json) | Azure Monitor Workbook combining several queries into one visual dashboard |
| [`docs/architecture.md`](docs/architecture.md) | Design rationale, table-naming realities, and cost model |
| [`docs/architecture-diagram.md`](docs/architecture-diagram.md) | Visual diagram of the data flow from source resources to dashboard |
| [`docs/setup-guide.md`](docs/setup-guide.md) | Full reproduction steps with screenshot evidence points |
| [`docs/screenshots/`](docs/screenshots/) | Evidence of the workspace, queries, and Workbook actually working |

## Resources Connected

| Source Resource | From Project | What It Contributes |
|---|---|---|
| `stmigrationlabjane01` (Storage) | Data Migration Lab | Blob read/write/delete operation logs |
| `stbatchstreamjane01` (Storage) | Batch & Streaming Lab | Blob read/write/delete operation logs |
| `kv-secpostlab-jane01` (Key Vault) | Security Posture Lab | Secret access audit events - the data-plane audit trail that project's Activity Log fallback couldn't show |
| `aa-cost-governance-lab` (Automation Account) | Cost Governance Lab | Runbook job execution logs |
| Data Factory (name varies) | Batch & Streaming Lab | Pipeline, activity, and trigger run history |

## Cost

- **Log Analytics workspace**: a genuine always-free monthly ingestion grant
  covers this lab's data volume comfortably - see `docs/architecture.md` for
  the exact allowance
- **Diagnostic settings**: no charge for the setting itself, only for the
  data it sends (covered by the free grant above)
- **Azure Monitor Workbook**: free
- **Alert rules** (optional, documented separately): small per-rule cost,
  same honest caveat used elsewhere in this portfolio - not part of the
  guaranteed-free core scope

## Setup Guide

Full steps: [`docs/setup-guide.md`](docs/setup-guide.md).

## Skills Demonstrated

- **Centralised observability design**: one workspace, multiple resource
  types, rather than checking each resource's own blade in isolation
- **KQL query authorship**: real operational questions expressed as queries,
  not just copy-pasted examples
- **Azure Monitor Workbooks**: combining multiple data sources into a single
  visual dashboard
- **Diagnostic settings across heterogeneous resource types**: understanding
  that log categories and destination table naming genuinely differ by
  resource type, and designing around that rather than assuming uniformity
- **Portfolio-level thinking**: treating five separate projects as parts of
  one environment worth monitoring together, not five unrelated exercises

## Author

Jane - Cloud & Infrastructure Engineer, AZ-104 candidate.
Capstone project drawing on the Cloud Cost Governance, On-Premise to Cloud
Data Migration, Batch & Streaming Pipeline, and Cloud Security Posture &
Secrets Management labs.