

# GitHub Copilot Agent Skills

Forked from https://github.com/thomast1906/github-copilot-agent-skills/ and updated for usage in Miljødirektoratet.

A growing collection of GitHub Copilot agents and reusable skills designed to extend Copilot's capabilities across engineering, dependency patching, and architecture workflows. Skills are domain-specific bundles of knowledge, prompting logic, and MCP tool usage that Copilot loads automatically when relevant.

## Structure

```
.github/
├── agents/
└── skills/
└── instructions/
└── prompts/
```

## Prerequisites

### Always Required

- VS Code (or VS Code Insiders)
- **[GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)** extension with Copilot Chat enabled

### MCP Servers

Some skills require MCP servers to be active. This repository includes a pre-configured `.vscode/mcp.json` for the servers below. VS Code will prompt you to start them when first used.

| MCP Server | Skills that use it | Setup |
|---|---|---|
| **Azure MCP** (via VS Code extension) | `azure-pricing`, `cost-optimization`, `waf-assessment`, `architecture-design` | Install the **[Azure Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-github-copilot)** VS Code extension — the Azure MCP Server registers automatically, no `mcp.json` entry needed |
| **Draw.io MCP** (`https://mcp.draw.io/mcp`) | `azure-drawio-mcp-diagramming`, `drawio-mcp-diagramming` | Included in `.vscode/mcp.json` — no additional install required |
| **Excalidraw MCP** (`https://mcp.excalidraw.com`) | `excalidraw-mcp-diagramming` | Included in `.vscode/mcp.json` — no additional install required |
| **Terraform MCP** (Docker image `hashicorp/terraform-mcp-server`) | `terraform-provider-upgrade` | Included in `.vscode/mcp.json` — requires **Docker** to be running; optionally provide a HCP Terraform/TFE token when prompted |

## Agents

Agents are pre-configured Copilot modes with domain-specific instructions and tool access. Invoke them from the Copilot Chat agent picker.

| Agent file | Name | What it does |
|---|---|---|
| `apim-policy-author.agent.md` | APIM Policy Author | Generates production-ready Azure API Management policy XML for authentication (OAuth 2.0, JWT, subscription keys), rate limiting, CORS, error handling, and request/response transformations |
| `azure-architect.agent.md` | Azure Architect | Designs production-ready Azure architectures aligned to the Well-Architected Framework and Cloud Adoption Framework; produces HLD documents with service selection, cost estimates, and IaC |
| `dependency-patch-manager.agent.md` | Dependency Patch Manager | Patches software libraries and runtime versions safely; avoids local Docker builds when a Dockerfile is present, uses LTS runtime targets, and relies on draft PR workflows plus GitHub Actions for final verification |
| `gh-aw-builder.agent.md` | GitHub Agentic Workflow Builder | Creates and configures markdown-based GitHub Agentic Workflows (gh-aw) with correct frontmatter, MCP server wiring, safe-outputs, and best practices |
| `terraform-change-manager.agent.md` | Terraform Change Manager | Implements Terraform code changes without running Terraform locally; commits and pushes branch changes, opens a draft PR, and relies on GitHub Actions plan output |
| `terraform-provider-upgrade.agent.md` | Terraform Provider Upgrade | Safely upgrades Terraform providers, detects breaking changes, migrates removed resources using `moved` blocks, and validates compatibility |

## Skills

Skills are invoked automatically by Copilot based on relevance, or explicitly by name in chat.

> 🚧 **WIP** — Skills marked with 🚧 WIP are under active development. They are functional but may have incomplete coverage, rough edges, or breaking changes as they evolve.

### Azure Architecture & Design

| Skill | Description |
|---|---|
| `architecture-design` | Designs Azure solutions from requirements — service selection, WAF alignment, cost estimates, and HLD output. Uses **Azure MCP** for live pricing. |
| `waf-assessment` | Assesses an architecture against all five WAF pillars (Reliability, Security, Cost, Operational Excellence, Performance) and provides scored recommendations. Uses **Azure MCP**. |
| `cost-optimization` 🚧 WIP | Identifies cost reduction opportunities across Azure workloads, quantifies savings, and calculates ROI. Uses **Azure MCP**. |
| `azure-pricing` | Looks up real-time Azure retail pricing for any service, SKU, or region; estimates costs from Bicep/ARM/Terraform templates; compares Consumption vs Reservation pricing. Defaults to GBP. Uses **Azure MCP**. |


### Infrastructure as Code

| Skill | Description |
|---|---|
| `terraform-provider-upgrade` | Safe Terraform provider upgrades with breaking change detection, automatic resource migration using `moved` blocks, and state management. Uses **Terraform MCP**. |

### Dependency Management

| Skill | Description |
|---|---|
| `dotnet-outdated` | Uses the `dotnet-outdated` global tool to report and upgrade outdated NuGet packages, preferring the latest stable version first and stepping back only when build, test, or compatibility issues require it. |

### Diagramming

| Skill | Description |
|---|---|
| `azure-drawio-mcp-diagramming` | Creates and edits Azure architecture diagrams via the Draw.io MCP; Azure-only icon library with icon catalog and rendering troubleshooting. Uses **Draw.io MCP**. |
| `drawio-mcp-diagramming` | Creates and edits architecture diagrams via the Draw.io MCP; supports both Azure2 and AWS4 icon libraries. Uses **Draw.io MCP**. |

### GitHub Workflows & Package Management

| Skill | Description |
|---|---|
| `gh-aw-operations` | Comprehensive knowledge for creating, debugging, and managing GitHub Agentic Workflows (gh-aw) — frontmatter spec, MCP wiring, safe-outputs, and common patterns |
| `apm-package-author` | Creates and maintains [APM (Agent Package Manager)](https://microsoft.github.io/apm/) manifests for distributing GitHub Copilot skills, agents, and MCP servers as installable packages. Covers `apm.yml` authoring, package structure, MCP dependency wiring, branch-based installs, and troubleshooting. |

## Getting Started

---

### Option A - Symlinks

1. Clone this repository.
2. Create symlinks via the (./New-AgentSkillSymlinks.ps1)[./New-AgentSkillSymlinks.ps1] script
   1. This script assumes placement of the cloned repo in the same root folder as your target repositories.
