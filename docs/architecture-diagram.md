# Architecture Diagram

```mermaid
flowchart TB
    subgraph Sources["Source Resources (From Earlier Projects)"]
        direction TB
        S1[Storage - Migration Lab - stmigrationlabjane01]
        S2[Storage - Batch Lab - stbatchstreamjane01]
        S3[Key Vault - Security Lab - kv-secpostlab-jane01]
        S4[Automation Account - Cost Lab - aa-cost-governance-lab]
        S5[Data Factory - Batch Lab]
    end

    subgraph Workspace["Shared Log Analytics Workspace"]
        direction TB
        W1[Diagnostic Settings per resource type]
        W2[Resource-specific tables]
    end

    subgraph Consumption["Querying and Visualization"]
        direction TB
        Q1[KQL Query Library]
        Q2[Azure Monitor Workbook]
        Q3[Alert Rule - optional]
    end

    S1 --> W1
    S2 --> W1
    S3 --> W1
    S4 --> W1
    S5 --> W1
    W1 --> W2
    W2 --> Q1
    Q1 --> Q2
    Q1 -.-> Q3

    style Sources fill:#fce8e6,stroke:#d93025
    style Workspace fill:#e8f4fd,stroke:#1a73e8
    style Consumption fill:#e6f4ea,stroke:#188038
```

## Reading This Diagram

**Sources (top, red):** five resources spanning four earlier projects,
deliberately not new infrastructure built just to have something to
monitor.

**Workspace (middle, blue):** the single point of convergence.

**Consumption (bottom, green):** the actual value this creates - queries
answering real operational questions, a Workbook making that visual and
persistent, and an alert rule turning it proactive.