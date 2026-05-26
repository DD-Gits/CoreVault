<#
.SYNOPSIS
Repairs an existing Obsidian project by adding any files or folders that are
missing relative to the current project template. Never overwrites existing
content.

.DESCRIPTION
This script walks the project template tree (System\Templates\Projects\<Type>)
and copies any files or folders that don't exist in the target project. Useful
when the template has evolved (new folders like Plans/, Slices/, Specs/,
References/, or new files like AGENTS.md) and existing projects need to catch
up without disturbing their current content.

What it does:
  - Auto-detects the vault from the script's own location.
  - Resolves the project path (via -ProjectPath, or -ProjectName + -ProjectType,
    or an interactive prompt).
  - Determines the project type (Work / Personal) from the path.
  - For each file/folder in the template that's MISSING from the project,
    copies it. Existing items are skipped — never overwritten.
  - Fills the `project:` frontmatter field on newly-added files (template files
    ship with a blank `project:` field).
  - Prints a summary of added folders, added files, and skipped (existing) items.

What it deliberately does NOT do (v1):
  - Touch any existing file content (no in-place modification of existing files).
  - Refresh helper skills (.claude/skills/ and .agents/skills/) — those are
    personal copies, not synced from the library by Repair.
  - Modify the project's .gitignore beyond adding it if missing.
  - Handle Clone-mode specifics — a cloned repo's root .gitignore is not
    overwritten (because Repair never overwrites), but the script also doesn't
    do anything special for the _meta\.gitignore convention. Treat Clone-mode
    projects manually if you need to repair their gitignore layout.

.PARAMETER VaultPath
Path to the vault. Auto-detected from script location if omitted.

.PARAMETER ProjectPath
Full path to the project folder to repair. Overrides ProjectName/ProjectType.

.PARAMETER ProjectName
Name of the project folder. Used with ProjectType to build the path. If
ProjectType is omitted, the script searches both Work and Personal.

.PARAMETER ProjectType
Work or Personal. Used with ProjectName, or inferred from ProjectPath.

.PARAMETER DryRun
Preview changes without writing any files.

.EXAMPLE
.\Repair-ObsidianProject.ps1 -ProjectName "My Project"

.EXAMPLE
.\Repair-ObsidianProject.ps1 -ProjectPath "$env:USERPROFILE\Obsidian\Vault\02 - Projects\Work\My Project" -DryRun

.NOTES
Safe to re-run. Existing files are never modified or overwritten.
#>

param (
    [string]$VaultPath = "",

    [string]$ProjectPath = "",

    [string]$ProjectName = "",

    [ValidateSet("", "Work", "Personal")]
    [string]$ProjectType = "",

    [switch]$DryRun
)

# ------------------------------------------------------------
# Auto-detect vault path if not supplied
# ------------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($VaultPath)) {
    if ($PSScriptRoot) {
        try {
            $candidate = (Get-Item $PSScriptRoot).Parent.Parent.FullName
            if (Test-Path -Path (Join-Path $candidate "CLAUDE.md")) {
                $VaultPath = $candidate
            }
        } catch {}
    }
    if ([string]::IsNullOrWhiteSpace($VaultPath)) {
        $VaultPath = Join-Path $env:USERPROFILE "Obsidian\Vault"
    }
}

# ------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------

function Read-RequiredValue {
    param ([string]$PromptText, [string]$CurrentValue)
    if (-not [string]::IsNullOrWhiteSpace($CurrentValue)) { return $CurrentValue.Trim() }
    do {
        $Value = Read-Host $PromptText
        if ([string]::IsNullOrWhiteSpace($Value)) {
            Write-Host "This value is required." -ForegroundColor Yellow
        }
    } while ([string]::IsNullOrWhiteSpace($Value))
    return $Value.Trim()
}

function Set-FrontmatterField {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Field,
        [Parameter(Mandatory = $true)][string]$Value
    )

    if (-not (Test-Path -Path $Path)) { return }

    $Content = Get-Content -Path $Path -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($null -eq $Content) { return }

    # Only edit within the frontmatter block at the top of the file.
    if ($Content -notmatch '^\s*---\s*\r?\n([\s\S]*?)\r?\n---\s*\r?\n') { return }

    $Pattern = "(?m)^(?<field>$([regex]::Escape($Field))):.*$"
    $Replacement = "`${field}: $Value"

    $NewContent = [regex]::Replace($Content, $Pattern, $Replacement, 1)

    if ($NewContent -ne $Content) {
        Set-Content -Path $Path -Value $NewContent -Encoding UTF8
    }
}

function Get-ProjectsForName {
    param ([string]$VaultPath, [string]$ProjectName)
    $found = @()
    foreach ($t in @("Work", "Personal")) {
        $candidate = Join-Path $VaultPath "02 - Projects\$t\$ProjectName"
        if (Test-Path -Path $candidate) {
            $found += @{ Path = $candidate; Type = $t }
        }
    }
    return $found
}

# ------------------------------------------------------------
# Resolve project path
# ------------------------------------------------------------

Write-Host ""
Write-Host "Repair Obsidian project" -ForegroundColor Cyan
Write-Host "-----------------------" -ForegroundColor Cyan

if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
    # Direct path supplied; nothing to resolve.
} elseif (-not [string]::IsNullOrWhiteSpace($ProjectName)) {
    if (-not [string]::IsNullOrWhiteSpace($ProjectType)) {
        $ProjectPath = Join-Path $VaultPath "02 - Projects\$ProjectType\$ProjectName"
    } else {
        $matches = Get-ProjectsForName -VaultPath $VaultPath -ProjectName $ProjectName
        if ($matches.Count -eq 0) {
            throw "Project '$ProjectName' not found under '$VaultPath\02 - Projects\Work' or '\Personal'."
        }
        if ($matches.Count -gt 1) {
            throw "Project name '$ProjectName' is ambiguous (found in both Work and Personal). Specify -ProjectType."
        }
        $ProjectPath = $matches[0].Path
        $ProjectType = $matches[0].Type
    }
} else {
    # Interactive prompt
    $ProjectPath = Read-RequiredValue -PromptText "Project path (full path to project folder)" -CurrentValue ""
}

# ------------------------------------------------------------
# Validate project and resolve template
# ------------------------------------------------------------

if (-not (Test-Path -Path $ProjectPath)) {
    throw "Project not found: $ProjectPath"
}
$ProjectPath = (Resolve-Path $ProjectPath).Path
$ProjectFolderName = Split-Path -Leaf $ProjectPath

# Infer type from path if not already set
if ([string]::IsNullOrWhiteSpace($ProjectType)) {
    $parent = Split-Path -Leaf (Split-Path -Parent $ProjectPath)
    if ($parent -eq "Work" -or $parent -eq "Personal") {
        $ProjectType = $parent
    } else {
        throw "Cannot determine project type from path. Parent folder is '$parent' (expected 'Work' or 'Personal'). Specify -ProjectType."
    }
}

$TemplatePath = Join-Path $VaultPath "System\Templates\Projects\$ProjectType"
if (-not (Test-Path -Path $TemplatePath)) {
    throw "Template not found: $TemplatePath"
}

Write-Host ""
Write-Host "Project: $ProjectPath"
Write-Host "Type:    $ProjectType"
Write-Host "Template: $TemplatePath"
if ($DryRun) { Write-Host "Mode:    DRY RUN (no changes will be written)" -ForegroundColor Yellow }
Write-Host ""

# ------------------------------------------------------------
# Walk template tree, copy missing items
# ------------------------------------------------------------

$addedFolders = @()
$addedFiles   = @()
$skippedFiles = @()

# Process directories first (so files have their parent dirs ready), then files.
Get-ChildItem -Path $TemplatePath -Recurse -Force -Directory | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($TemplatePath.Length).TrimStart('\','/')
    $dest = Join-Path $ProjectPath $rel
    if (-not (Test-Path -Path $dest)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
        }
        $addedFolders += $rel
    }
}

Get-ChildItem -Path $TemplatePath -Recurse -Force -File | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($TemplatePath.Length).TrimStart('\','/')
    $dest = Join-Path $ProjectPath $rel
    if (-not (Test-Path -Path $dest)) {
        if (-not $DryRun) {
            $destParent = Split-Path -Parent $dest
            if (-not (Test-Path -Path $destParent)) {
                New-Item -ItemType Directory -Path $destParent -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $dest -Force
            Set-FrontmatterField -Path $dest -Field "project" -Value $ProjectFolderName
        }
        $addedFiles += $rel
    } else {
        $skippedFiles += $rel
    }
}

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host ""
if ($DryRun) {
    Write-Host "=== DRY RUN SUMMARY (nothing was written) ===" -ForegroundColor Yellow
} else {
    Write-Host "=== Repair summary ===" -ForegroundColor Green
}

Write-Host ""
Write-Host "Added folders ($($addedFolders.Count)):" -ForegroundColor Cyan
if ($addedFolders.Count -eq 0) { Write-Host "  (none)" -ForegroundColor DarkGray }
$addedFolders | ForEach-Object { Write-Host "  + $_" }

Write-Host ""
Write-Host "Added files ($($addedFiles.Count)):" -ForegroundColor Green
if ($addedFiles.Count -eq 0) { Write-Host "  (none)" -ForegroundColor DarkGray }
$addedFiles | ForEach-Object { Write-Host "  + $_" }

Write-Host ""
Write-Host "Skipped (already present, $($skippedFiles.Count) files):" -ForegroundColor DarkGray
if ($skippedFiles.Count -le 20) {
    $skippedFiles | ForEach-Object { Write-Host "  = $_" -ForegroundColor DarkGray }
} else {
    $skippedFiles | Select-Object -First 20 | ForEach-Object { Write-Host "  = $_" -ForegroundColor DarkGray }
    Write-Host "  ... and $($skippedFiles.Count - 20) more" -ForegroundColor DarkGray
}

Write-Host ""
if ($DryRun) {
    Write-Host "Re-run without -DryRun to apply." -ForegroundColor Yellow
} elseif (($addedFolders.Count + $addedFiles.Count) -eq 0) {
    Write-Host "Nothing to repair — project is already in sync with the template." -ForegroundColor Green
} else {
    Write-Host "Repair complete. Newly-added files have their 'project:' frontmatter set to '$ProjectFolderName'." -ForegroundColor Green
    Write-Host "Review the additions and fill in any other frontmatter or content as needed." -ForegroundColor Green
}
Write-Host ""
