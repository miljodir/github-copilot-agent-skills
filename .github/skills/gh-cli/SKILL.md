---
name: gh-cli
description: GitHub CLI (gh) workflow for branch-based changes, draft pull requests, and GitHub Actions status checks when patching code or validating automated updates.
---

# GitHub CLI (gh)

Use GitHub CLI to manage branch-based changes, draft pull requests, and workflow inspection from the command line.


## Prerequisites

gh cli is already installed and authenticated with standard permissions.

## When to Use This Skill

Activate this skill when users ask questions related to:

- Github CLI commands for managing repositories, pull requests, issues, and workflows.
- Automating security tasks using GitHub CLI.
- Branching, pushing, creating draft pull requests, or checking GitHub Actions results as part of a code change workflow.

## Goal

Do not work directly on the default branch. Use git for branch-based commits, push the branch, create or reuse a **draft** pull request with `gh`, and inspect the pull-request workflow runs before finishing.

## Standard Workflow

1. **Check the current branch**
   - `git rev-parse --abbrev-ref HEAD`
2. **Handle branching correctly**
   - Stay on the current branch unless it is `main`
   - If the current branch is `main`, create a descriptive feature branch first
3. **Commit and push**
   - Stage only the intended files
   - Commit with a descriptive message
   - Push the branch before PR creation
4. **Create or reuse the draft PR**
   - If a PR already exists for the branch, reuse it
   - Otherwise create a draft PR with `gh pr create --draft`
5. **Inspect the PR-triggered workflow**
   - Check the latest `pull_request` run
   - Read failed logs when available
   - If no run appears immediately, wait briefly and rerun the same `gh` checks rather than replacing CI with an ad hoc local workflow

Target repositories should have pre-existing GitHub Actions for build, test, validation, or plan execution when pull requests are created and updated.

## Core Commands

### Check the current branch

```bash
git rev-parse --abbrev-ref HEAD
```

### Push the current branch

Existing upstream:

```bash
git push
```

If Remote changes come in conflict with your pushes:
```bash
git branch --set-upstream-to="origin/$(git branch --show-current)" (git branch --show-current) && git pull && git push
```


New upstream:

```bash
git push --set-upstream origin <branch>
```

### Create a draft pull request

```bash
gh pr create --draft --fill
```

If you want an explicit title and body:

```bash
gh pr create --draft --title "<title>" --body "<body>"
```

### Reuse an existing PR for the branch

```bash
gh pr list --head <branch> --json number,url,title,isDraft --limit 1
```

### Inspect the latest PR workflow

Use this PowerShell pattern:

```powershell
$ghRuns = gh run list -e pull_request -L 1 --json databaseId,event,updatedAt,workflowName,conclusion | ConvertFrom-Json
gh run view $ghRuns.databaseId --log-failed
```

If you need to force the target repository, add `-R owner/repo` to the `gh` commands.

## Guidance

- Prefer draft PRs for automated or agent-driven code changes
- Push before creating the PR so the branch exists remotely
- Avoid duplicate PRs for the same branch
- Use workflow output as the final gate when the repository relies on CI for build, test, Docker, or Terraform validation
- Report blockers plainly if GitHub authentication, permissions, branch protections, or workflows prevent progress
