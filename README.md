# GitHub Copilot Agent Skills

Forked from [thomast1906/github-copilot-agent-skills](https://github.com/thomast1906/github-copilot-agent-skills) and curated for Miljodirektoratet. This fork retains Miljodir's agents, skills, instructions, prompts, and package ownership while incorporating upstream improvements.

A collection of reusable skills and Copilot agents for Azure architecture, Terraform, dependency patching, diagramming, GitHub Agentic Workflows, and skill authoring.

## Installation

Use a personal, copy-based installation rather than symlinking repositories. Install only the skills you need, or use APM for curated bundles with agents and declared MCP dependencies.

### Option 1 - GitHub CLI personal skills (recommended for Copilot)

With a recent [GitHub CLI](https://cli.github.com/) that includes `gh skill`, install a skill for your user:

```powershell
gh skill install miljodir/github-copilot-agent-skills azure-pricing --allow-hidden-dirs --agent github-copilot --scope user
gh skill update azure-pricing
```

Replace `azure-pricing` with any skill in the tables below. `--allow-hidden-dirs` is required because this fork stores skills in both `.agents/skills` and `.github/skills`. User scope makes the installed skill available across projects without repository symlinks.

To list discoverable skills without installing anything, omit the skill name and `--all` and pipe noninteractively:

```powershell
gh skill install miljodir/github-copilot-agent-skills --allow-hidden-dirs --agent github-copilot --scope user | Out-String
```

`gh skill` installs skills only: it does not install agents, prompts, instructions, or MCP configuration. Configure the [MCP servers](#mcp-servers) separately when a skill needs them.

### Option 2 - skills CLI personal copies

For other supported clients, select skills and your client through the [skills CLI](https://skills.sh/):

```powershell
npx skills add miljodir/github-copilot-agent-skills --global --copy
```

Keep both `--global` (user scope) and `--copy` (no symlinks). This installs skills, not the repository's agents or MCP configuration. Upstream's skills.sh catalogue describes upstream content, not necessarily this fork's curated selection.

### Option 3 - APM curated bundles

Install [APM](https://microsoft.github.io/apm/getting-started/installation/) and use a current version with `--global` and `--target` support.

**Personal Copilot installation:**

```powershell
apm install miljodir/github-copilot-agent-skills --global --target copilot
# Or select one bundle:
apm install miljodir/github-copilot-agent-skills/packages/terraform --global --target copilot
```

APM installs skills, agents, and other supported primitives at user scope. Copilot user-scope support is partial and client-specific: Copilot CLI and VS Code do not necessarily consume the same global agents, instructions, prompts, or MCP configuration. Consult the [APM target matrix](https://microsoft.github.io/apm/reference/targets-matrix/) rather than assuming every personal primitive works in every IDE.

**Project installation for VS Code with Copilot:**

```powershell
apm install miljodir/github-copilot-agent-skills --target copilot --runtime vscode
```

Run this inside the target project. APM deploys supported agents and MCP configuration for that target; skills normally use `.agents/skills`. APM may require explicit trust or declaration for transitive MCP dependencies: review the declared servers before granting trust.

**Individual bundles** (add the same scope/target flags):

```powershell
apm install miljodir/github-copilot-agent-skills/packages/architect --global --target copilot
apm install miljodir/github-copilot-agent-skills/packages/terraform --global --target copilot
apm install miljodir/github-copilot-agent-skills/packages/dependency-patching --global --target copilot
apm install miljodir/github-copilot-agent-skills/packages/diagramming --global --target copilot
apm install miljodir/github-copilot-agent-skills/packages/drawio-mcp-diagramming --global --target copilot
```

### Option 4 - Clone for source and contributions

```powershell
git clone https://github.com/miljodir/github-copilot-agent-skills.git
```

Open the clone in VS Code with [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) and Copilot Chat enabled. Configure relevant MCP servers, then invoke a skill explicitly or choose an available agent in the agent picker.

Cloning does not install agents or skills into other projects. `New-AgentSymlinks.ps1` is a legacy script, not the recommended installer: it removes existing destination directories in sibling repositories. Do not run it for personal installation.

## Available skills

Stable curated skills are listed with their APM bundle. Standalone skills can be installed individually with `gh skill`; WIP skills are excluded from curated bundles. APIM and Excalidraw skills deliberately removed by this fork are not reintroduced by upstream synchronization.

### Azure architecture

| Skill | Description | APM bundle |
|---|---|---|
| [`architecture-design`](.agents/skills/architecture-design) | Designs Azure solutions, selects services, and produces WAF/CAF-aligned HLD documentation. | `packages/architect` |
| [`waf-assessment`](.agents/skills/waf-assessment) | Assesses all five Azure Well-Architected Framework pillars. | `packages/architect` |
| [`azure-pricing`](.github/skills/azure-pricing) | Looks up live retail pricing, estimates template costs, and compares pricing types; defaults to GBP. | `packages/architect` |
| [`cost-optimization`](.github/skills/cost-optimization) | Identifies savings opportunities and estimates ROI. **WIP**. | - |

### Terraform and dependency management

| Skill | Description | APM bundle |
|---|---|---|
| [`terraform-module-creator`](.agents/skills/terraform-module-creator) | Creates maintainable Terraform modules with Azure-focused patterns, versioning, and validation guidance. | `packages/terraform` |
| [`terraform-provider-upgrade`](.agents/skills/terraform-provider-upgrade) | Handles provider breaking changes and resource migrations with `moved` blocks. | `packages/terraform` |
| [`dotnet-outdated`](.agents/skills/dotnet-outdated) | Discovers and upgrades NuGet packages while prioritizing build and test compatibility. | `packages/dependency-patching` |

### Diagramming

| Skill | Description | APM bundle |
|---|---|---|
| [`drawio-mcp-diagramming`](.agents/skills/drawio-mcp-diagramming) | Creates Draw.io XML, Mermaid, and CSV diagrams with shape discovery, routing, and standalone-file guidance. | `packages/diagramming`, `packages/drawio-mcp-diagramming` |
| [`azure-drawio-mcp-diagramming`](.agents/skills/azure-drawio-mcp-diagramming) | Azure-focused diagrams with local icon catalogue and rendering troubleshooting. | `packages/diagramming` |

### GitHub workflows and authoring

| Skill | Description | APM bundle |
|---|---|---|
| [`gh-cli`](.github/skills/gh-cli) | Branch-based changes, PRs, and GitHub Actions inspection. | `packages/dependency-patching` |
| [`gh-aw-operations`](.agents/skills/gh-aw-operations) | Creates, compiles, debugs, and manages GitHub Agentic Workflows. | `packages/terraform` |
| [`skill-creator`](.agents/skills/skill-creator) | Scaffolds and validates skills with supporting scripts and references. | - |
| [`apm-package-author`](.agents/skills/apm-package-author) | Authors and troubleshoots APM manifests and MCP dependencies. | - |

## Agents

APM installs bundled agents for the selected client. `.agents/*.agent.md` is this fork's optional source catalogue, not Copilot's native `.github/agents` installation directory.

| Agent | Description | APM bundle |
|---|---|---|
| [`azure-architect`](.agents/azure-architect.agent.md) | Azure architectures and HLD documentation aligned to WAF and CAF. | `packages/architect` |
| [`terraform-provider-upgrade`](.agents/terraform-provider-upgrade.agent.md) | Structured provider upgrades and compatibility checks. | `packages/terraform` |
| [`terraform-change-manager`](.github/agents/terraform-change-manager.agent.md) | Terraform changes through PRs and GitHub Actions plans, without local Terraform execution. | `packages/terraform` |
| [`gh-aw-builder`](.agents/gh-aw-builder.agent.md) | GitHub Agentic Workflows with MCP wiring and safe outputs. | `packages/terraform` |
| [`dependency-patch-manager`](.agents/dependency-patch-manager.agent.md) | Safe library/runtime patching with LTS targets and CI verification. | `packages/dependency-patching` |
| [`dotnet-upgrade`](.agents/dotnet-upgrade.agent.md) | Guided .NET modernization. | Source only |
| [`apim-policy-author`](.agents/apim-policy-author.agent.md) | Optional APIM policy author; companion APIM skills are not included in this fork. | Source only |

## MCP servers

Skills may call MCP servers for live data or diagram editing. Package manifests declare their MCP dependencies; direct clones include [`.vscode/mcp.json`](.vscode/mcp.json). Skill-only installs do not copy that configuration.

| Server | Used by | Setup |
|---|---|---|
| Azure MCP | Architecture, assessment, pricing, cost optimization, Terraform module creation | Install the [Azure Tools](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-github-copilot) extension for VS Code; the server registers automatically. Other clients need their own Azure MCP setup. |
| Draw.io MCP | Both Draw.io skills | HTTP server `https://mcp.draw.io/mcp` declared in diagramming bundles and the clone's config. The general Draw.io skill also documents the stdio tool server. |
| Terraform MCP | Terraform provider upgrades and module creation | Docker image `hashicorp/terraform-mcp-server:0.5.1`; requires Docker. HCP Terraform/Enterprise credentials are optional for public registry use. |

The clone also retains an optional Excalidraw MCP entry, but no Excalidraw skill or curated package dependency.

## Repository structure

```text
.agents/
  *.agent.md                  Optional agent source catalogue
  skills/                     Specialized skills and their references/scripts
.github/
  agents/                     Common Copilot agents
  skills/                     Common skills (including WIP cost optimization)
  instructions/               Miljodir instructions
  prompts/                    Miljodir prompts
  scripts/                    Validation
  workflows/                  CI
packages/
  architect/
  terraform/
  dependency-patching/
  diagramming/
  drawio-mcp-diagramming/
apm.yml                       Root curated package
```

## Creating or contributing a skill

Add specialized skills under `.agents/skills/<skill-name>/`; commonly used skills may live in `.github/skills/`. Each folder needs a `SKILL.md`; supporting material belongs in `references/` and helpers in `scripts/`.

1. Create a feature branch and update the skill.
2. Run `bash .github/scripts/validate-agent-skills.sh` from the repository root.
3. Update package dependencies if applicable, using paths in this fork's actual tree.
4. Open a PR targeting Miljodir's `main`. The [validation workflow](.github/workflows/validate-skills.yaml) covers both skill locations, agents, and package/validation changes.

Use [`skill-creator`](.agents/skills/skill-creator) for scaffolding and validation, and [`apm-package-author`](.agents/skills/apm-package-author) for package authoring.

## Licence

Package manifests declare MIT, inherited from upstream. See the [MIT licence text](https://opensource.org/licenses/MIT).
