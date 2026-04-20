$scriptRoot = Split-Path -Parent $PSCommandPath
$reposRoot = Split-Path -Parent $scriptRoot
$sharedGithubRoot = Join-Path $scriptRoot ".github"

$agentsTarget = Join-Path $sharedGithubRoot "agents"
$instructionsTarget = Join-Path $sharedGithubRoot "instructions"
$promptsTarget = Join-Path $sharedGithubRoot "prompts"
$skillsTarget = Join-Path $sharedGithubRoot "skills"

function Remove-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $existingItem = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -ne $existingItem) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

function Set-SymbolicLink {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    Remove-ExistingPath -Path $Path
    New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
}

Get-ChildItem -LiteralPath $reposRoot -Directory | Where-Object {
    $_.Name -like "wl-*" -or $_.Name -like "cp-*"
} | ForEach-Object {
    $repoPath = $_.FullName
    $repoGithubRoot = Join-Path $repoPath ".github"

    New-Item -ItemType Directory -Path $repoGithubRoot -Force | Out-Null

    Set-SymbolicLink -Path (Join-Path $repoGithubRoot "agents") -Target $agentsTarget
    Set-SymbolicLink -Path (Join-Path $repoGithubRoot "instructions") -Target $instructionsTarget
    Set-SymbolicLink -Path (Join-Path $repoGithubRoot "prompts") -Target $promptsTarget
    Set-SymbolicLink -Path (Join-Path $repoGithubRoot "skills") -Target $skillsTarget

    $gitignorePath = Join-Path $repoPath ".gitignore"
    $entriesToAdd = @(
        ".github/agents",
        ".github/instructions",
        ".github/prompts",
        ".github/skills"
    )

    if (Test-Path -LiteralPath $gitignorePath) {
        $existingEntries = Get-Content -LiteralPath $gitignorePath

        foreach ($entry in $entriesToAdd) {
            if ($existingEntries -notcontains $entry) {
                Add-Content -LiteralPath $gitignorePath -Value $entry
            }
        }
    }
    else {
        $entriesToAdd | Set-Content -LiteralPath $gitignorePath
    }
}
