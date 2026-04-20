---
name: dotnet-outdated
description: Use the dotnet-outdated global tool to report and upgrade outdated NuGet packages while prioritizing successful build and test outcomes over blindly taking the newest version.
metadata:
  version: 1.0.0
  category: dependency-management
  tags: [dotnet, nuget, dependency-upgrades, package-patching]
---

# dotnet-outdated

Use [`dotnet-outdated`](https://github.com/dotnet-outdated/dotnet-outdated) to find and upgrade outdated NuGet packages in .NET solutions and projects.

## When to Use

- Upgrading outdated NuGet packages in `.sln`, `.slnx`, `.slnf`, `.csproj`, or `.fsproj` files
- Auditing which direct or transitive packages are behind
- Updating packages to the latest stable release by default
- Reducing upgrade scope when the newest package version breaks compilation, tests, or app behavior
- Producing machine-readable or markdown reports of dependency status

## Assumptions

- The correct major version of the .NET SDK is already installed
- Stable releases are preferred; do not use prerelease packages unless the user asks for them
- Build and test health matter more than taking every package to the absolute newest version

## Install or Update the Tool

Prefer updating first:

```bash
dotnet tool update --global dotnet-outdated-tool
```

If the tool is not installed yet:

```bash
dotnet tool install --global dotnet-outdated-tool
```

## Core Workflow

1. **Find the target**
   - Run against a solution, project, or directory
   - If no path is supplied, `dotnet outdated` uses the current directory
2. **Inspect before changing**
   - Start with a report-only run to see outdated packages
3. **Upgrade toward latest stable**
   - Use automatic upgrade for the first pass
4. **Build and test the repo**
   - Use the repository's existing commands after the upgrade
5. **Constrain only if needed**
   - If latest causes failures or breaking changes, retry with a major/minor lock or explicit maximum version

## Common Commands

### Report outdated packages

```bash
dotnet outdated <path> --pre-release Never
```

### Upgrade to the latest stable versions

```bash
dotnet outdated <path> --upgrade --pre-release Never
```

### Upgrade interactively

```bash
dotnet outdated <path> --upgrade:Prompt --pre-release Never
```

### Include transitive dependencies

```bash
dotnet outdated <path> --transitive --pre-release Never
```

### Stay within the current major version if latest breaks the repo

```bash
dotnet outdated <path> --upgrade --version-lock Major --pre-release Never
```

### Stay within the current minor version

```bash
dotnet outdated <path> --upgrade --version-lock Minor --pre-release Never
```

### Cap upgrades to a maximum version

```bash
dotnet outdated <path> --upgrade --maximum-version 8.0 --pre-release Never
```

### Save a report for review

```bash
dotnet outdated <path> --output dotnet-outdated.md --output-format markdown --pre-release Never
```

## Decision Rules

1. **Default target:** latest stable package version
2. **If latest breaks build/tests:** downgrade the target scope to the highest safe version
3. **If a package requires a framework jump:** do not force the framework upgrade unless the user asked for it
4. **If only certain packages should move:** use include/exclude filters or prompt mode

## Practical Patterns

### Safe first pass for most repos

```bash
dotnet outdated . --pre-release Never
dotnet outdated . --upgrade --pre-release Never
```

Then run the repo's normal restore, build, and test commands.

### Conservative pass when a major bump is risky

```bash
dotnet outdated . --upgrade --version-lock Major --pre-release Never
```

### Tight scope for one package family

```bash
dotnet outdated . --upgrade --include Serilog --pre-release Never
```

## Notes

- `dotnet outdated` can analyze a directory, solution, or project path
- `--upgrade` modifies project files, so review diffs and lockfile changes afterward
- Use `--transitive` when you need visibility into indirect dependencies
- Use `--output-format json`, `csv`, or `markdown` for reports

## References

- GitHub: <https://github.com/dotnet-outdated/dotnet-outdated>
- NuGet package: <https://www.nuget.org/packages/dotnet-outdated-tool/>
