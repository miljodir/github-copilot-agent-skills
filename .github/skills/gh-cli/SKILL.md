---
name: gh-cli
description: GitHub CLI (gh) simple reference to solve security issues and patching.
---

# GitHub CLI (gh)

Simple reference for GitHub CLI (gh) - work seamlessly with GitHub from the command line.


## Prerequisites

gh cli is already installed and authenticated with standard permissions.

## When to Use This Skill

Activate this skill when users ask questions related to:

- Github CLI commands for managing repositories, pull requests, issues, and workflows.
- Automating security tasks using GitHub CLI.

## Goal

Your goal is to fix security vulnerabilities and patching towards target repositories. Use the GitHub CLI to interact with repositories, manage pull requests, and automate security tasks.
Make sure you do not work on the default git branch, but are on a branch created for your work. Commit and push changes via git commands, then use gh cli to create pull requests and manage them.
Target repositories should have pre-existing Github Actions for building code when pull requests are created and synced, ensure that the build status and tests (if any) are passing before you finish your work 

## Commands

```pwsh
## Create with title and body
gh pr create `
  --title "Copilot: Add new functionality" `
  --body "This PR adds..." `
  --labels copilot,security

## Get Dependabot alerts
gh api /repos/miljodir/<foldername>/dependabot/alerts

## List workflow runs
gh run list

## List for specific workflow
gh run list --workflow "ci.yml"

```

