<#
.SYNOPSIS
Bootstraps a fresh Obsidian AI vault from the install package's templates/ folder.

.DESCRIPTION
This script lives in the install-package root alongside ./templates/ and ./scripts/.
It writes a complete vault to the user-specified path, copying:

  - Vault-root files (CLAUDE.md, CODEX.md, Vault-Guide.md, Vault-Map.md,
                      Session-Rituals.md, Obsidian-AI-User-Guide.md,
                      Obsidian-AI-Workflow-Guide.md)
  - Top-level folder structure (00 - Inbox through 09 - Archive, plus System/)
  - Note templates           -> System\Templates\Notes\
  - Project templates        -> System\Templates\Projects\Work\ and \Personal\
  - Skills library           -> 04 - Resources\AI\Skills\
  - Prompt library           -> 04 - Resources\AI\Prompts\
  - Presets library          -> 04 - Resources\AI\Presets\
  - Workflow docs            -> System\Workflows\
  - Seeded extras            -> top-level tasks, dashboards, area indexes
  - Operational scripts      -> System\Scripts\

All content lives in the install package's templates/ folder. Editing a
template there immediately affects future vaults - no heredoc duplication.

.PARAMETER VaultPath
Where to create the vault. If omitted, defaults to $env:USERPROFILE\Obsidian\Vault
(prompted for confirmation unless -NoConfirm is passed).

.PARAMETER ForceOverwrite
Overwrite existing files at the destination. Default: leave existing files in place.

.PARAMETER NoConfirm
Skip the interactive confirmation prompt. Useful for unattended runs.

.PARAMETER AllScripts
Copy both .py and .ps1 operational scripts to System\Scripts\, regardless of OS.
Default: copy only .ps1 (Windows-native) since this is the PowerShell bootstrapper.

.EXAMPLE
.\Create-ObsidianAiVault.ps1

.EXAMPLE
.\Create-ObsidianAiVault.ps1 -VaultPath "D:\Notes\MyVault" -NoConfirm -AllScripts

.NOTES
The install package must contain a templates/ folder alongside this script.
Run-time errors will be reported if expected template files are missing.
#>

param (
    [string]$VaultPath = "",
    [switch]$ForceOverwrite,
    [switch]$NoConfirm,
    [switch]$AllScripts
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Locate install package
# ------------------------------------------------------------

$PackageRoot = $PSScriptRoot
$TemplatesRoot = Join-Path $PackageRoot "templates"
$ScriptsRoot   = Join-Path $PackageRoot "scripts"

if (-not (Test-Path -Path $TemplatesRoot)) {
    throw "Templates folder not found at: $TemplatesRoot. This script must be run from the install package root."
}
if (-not (Test-Path -Path $ScriptsRoot)) {
    throw "Scripts folder not found at: $ScriptsRoot. This script must be run from the install package root."
}

# ------------------------------------------------------------
# Resolve vault path (default + confirmation)
# ------------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($VaultPath)) {
    $VaultPath = Join-Path $env:USERPROFILE "Obsidian\Vault"
}

if (-not $NoConfirm) {
    Write-Host ""
    Write-Host "Obsidian AI vault creation" -ForegroundColor Cyan
    Write-Host "--------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "About to create / update a vault at:"
    Write-Host "  $VaultPath" -ForegroundColor Yellow
    if (Test-Path -Path $VaultPath) {
        if ($ForceOverwrite) {
            Write-Host "  (path exists - existing files will be overwritten where -ForceOverwrite applies)" -ForegroundColor DarkGray
        } else {
            Write-Host "  (path exists - existing files will be left in place; pass -ForceOverwrite to overwrite)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  (path does not yet exist - it will be created)" -ForegroundColor DarkGray
    }
    Write-Host ""
    $response = Read-Host "Press Enter to continue, or type a different path (Ctrl+C to abort)"
    if (-not [string]::IsNullOrWhiteSpace($response)) {
        $VaultPath = $response.Trim()
    }
    Write-Host ""
    Write-Host "Using vault path: $VaultPath" -ForegroundColor Green
    Write-Host ""
}

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

function New-FolderIfMissing {
    param ([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        [void](New-Item -ItemType Directory -Path $Path -Force)
    }
}

function Copy-FileIfMissingOrForced {
    param (
        [string]$Source,
        [string]$Destination
    )
    if (-not (Test-Path -Path $Source)) {
        Write-Warning "Source missing, skipping: $Source"
        return $false
    }
    if ((Test-Path -Path $Destination) -and -not $ForceOverwrite) {
        return $false
    }
    $parent = Split-Path -Parent $Destination
    if ($parent) { New-FolderIfMissing -Path $parent }
    Copy-Item -Path $Source -Destination $Destination -Force
    return $true
}

function Copy-TreeIfMissingOrForced {
    param (
        [string]$Source,
        [string]$Destination
    )
    if (-not (Test-Path -Path $Source)) {
        Write-Warning "Source tree missing, skipping: $Source"
        return @{ Copied = 0; Skipped = 0 }
    }
    $copied = 0
    $skipped = 0
    foreach ($srcFile in (Get-ChildItem -Path $Source -Recurse -File -Force)) {
        $rel = $srcFile.FullName.Substring($Source.Length).TrimStart('\','/')
        $dst = Join-Path $Destination $rel
        if (Copy-FileIfMissingOrForced -Source $srcFile.FullName -Destination $dst) {
            $copied++
        } else {
            $skipped++
        }
    }
    return @{ Copied = $copied; Skipped = $skipped }
}

function Write-Section {
    param ([string]$Title)
    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("-" * $Title.Length) -ForegroundColor Cyan
}

# ------------------------------------------------------------
# Top-level vault skeleton
# ------------------------------------------------------------

$TopLevelFolders = @(
    "00 - Inbox",
    "01 - Calendar\Daily",
    "01 - Calendar\Weekly",
    "01 - Calendar\Monthly",
    "01 - Calendar\Reviews",
    "02 - Projects\Work",
    "02 - Projects\Personal",
    "03 - Areas\Work",
    "03 - Areas\Personal",
    "04 - Resources\AI\Prompts",
    "04 - Resources\AI\Skills",
    "04 - Resources\Technical",
    "04 - Resources\Reference",
    "05 - Tasks",
    "06 - Meetings",
    "07 - Messaging",
    "08 - Development",
    "09 - Archive\Projects",
    "09 - Archive\Resources",
    "System\Templates\Notes",
    "System\Templates\Projects\Work",
    "System\Templates\Projects\Personal",
    "System\Dashboards",
    "System\Scripts",
    "System\Workflows",
    "System\Attachments"
)

Write-Section "Building vault skeleton"
New-FolderIfMissing -Path $VaultPath
foreach ($folder in $TopLevelFolders) {
    New-FolderIfMissing -Path (Join-Path $VaultPath $folder)
}
Write-Host "Created $($TopLevelFolders.Count) top-level folders" -ForegroundColor Green

# ------------------------------------------------------------
# Vault-root files (CLAUDE.md, CODEX.md, Vault-Guide.md, Vault-Map.md,
# Session-Rituals.md, Obsidian-AI-User-Guide.md, Obsidian-AI-Workflow-Guide.md)
# ------------------------------------------------------------

Write-Section "Vault-root files"
$result = Copy-TreeIfMissingOrForced -Source (Join-Path $TemplatesRoot "vault") -Destination $VaultPath
Write-Host "Vault-root files: $($result.Copied) copied, $($result.Skipped) skipped" -ForegroundColor Green

# ------------------------------------------------------------
# Note templates
# ------------------------------------------------------------

Write-Section "Note templates"
$result = Copy-TreeIfMissingOrForced `
    -Source (Join-Path $TemplatesRoot "notes") `
    -Destination (Join-Path $VaultPath "System\Templates\Notes")
Write-Host "Note templates: $($result.Copied) copied, $($result.Skipped) skipped" -ForegroundColor Green

# ------------------------------------------------------------
# Project templates (Work and Personal)
# ------------------------------------------------------------

Write-Section "Project templates"
$result = Copy-TreeIfMissingOrForced `
    -Source (Join-Path $TemplatesRoot "projects") `
    -Destination (Join-Path $VaultPath "System\Templates\Projects")
Write-Host "Project templates: $($result.Copied) copied, $($result.Skipped) skipped" -ForegroundColor Green

# ------------------------------------------------------------
# Skills library
# ------------------------------------------------------------

Write-Section "Skills library"
$result = Copy-TreeIfMissingOrForced `
    -Source (Join-Path $TemplatesRoot "skills") `
    -Destination (Join-Path $VaultPath "04 - Resources\AI\Skills")
Write-Host "Skills: $($result.Copied) files copied, $($result.Skipped) skipped" -ForegroundColor Green

# ------------------------------------------------------------
# Prompt library
# ------------------------------------------------------------

Write-Section "Prompt library"
$result = Copy-TreeIfMissingOrForced `
    -Source (Join-Path $TemplatesRoot "prompts") `
    -Destination (Join-Path $VaultPath "04 - Resources\AI\Prompts")
Write-Host "Prompts: $($result.Copied) copied, $($result.Skipped) skipped" -ForegroundColor Green

# ------------------------------------------------------------
# Presets library
# ------------------------------------------------------------

Write-Section "Presets library"
$presetsSrc = Join-Path $TemplatesRoot "presets"
if (Test-Path -Path $presetsSrc) {
    $result = Copy-TreeIfMissingOrForced `
        -Source $presetsSrc `
        -Destination (Join-Path $VaultPath "04 - Resources\AI\Presets")
    Write-Host "Presets: $($result.Copied) copied, $($result.Skipped) skipped" -ForegroundColor Green
} else {
    Write-Host "(no presets folder in install package, skipping)" -ForegroundColor DarkGray
}

# ------------------------------------------------------------
# Workflow docs
# ------------------------------------------------------------

Write-Section "Workflow docs"
$result = Copy-TreeIfMissingOrForced `
    -Source (Join-Path $TemplatesRoot "workflows") `
    -Destination (Join-Path $VaultPath "System\Workflows")
Write-Host "Workflows: $($result.Copied) copied, $($result.Skipped) skipped" -ForegroundColor Green

# ------------------------------------------------------------
# Seeded extras (Tasks files, Inbox stub, Dashboards, Area indexes)
# ------------------------------------------------------------

Write-Section "Seeded extras"
$extrasSrc = Join-Path $TemplatesRoot "extras"
if (Test-Path -Path $extrasSrc) {
    $result = Copy-TreeIfMissingOrForced -Source $extrasSrc -Destination $VaultPath
    Write-Host "Extras: $($result.Copied) copied, $($result.Skipped) skipped" -ForegroundColor Green
} else {
    Write-Host "(no extras folder in install package, skipping)" -ForegroundColor DarkGray
}

# ------------------------------------------------------------
# Operational scripts -> System\Scripts\
# ------------------------------------------------------------

Write-Section "Operational scripts"
$scriptsDst = Join-Path $VaultPath "System\Scripts"

# PowerShell scripts (always copy on Windows native, since this is the PS bootstrapper)
$psScripts = @("New-ObsidianProject.ps1", "Repair-ObsidianProject.ps1")
# Python scripts (copy if -AllScripts, since they're cross-platform helpers)
$pyScripts = @("new_project.py", "repair_project.py", "vault_helpers.py")

$copiedCount = 0
foreach ($name in $psScripts) {
    if (Copy-FileIfMissingOrForced -Source (Join-Path $ScriptsRoot $name) -Destination (Join-Path $scriptsDst $name)) {
        $copiedCount++
    }
}
if ($AllScripts) {
    foreach ($name in $pyScripts) {
        if (Copy-FileIfMissingOrForced -Source (Join-Path $ScriptsRoot $name) -Destination (Join-Path $scriptsDst $name)) {
            $copiedCount++
        }
    }
}
Write-Host "Copied $copiedCount operational script(s) to System\Scripts\" -ForegroundColor Cyan

# ------------------------------------------------------------
# Obsidian per-vault settings
#
# Writes .obsidian/{app,templates,daily-notes,community-plugins}.json so the
# vault opens with the recommended settings from Vault-Guide.md without manual
# UI clicks. Honours -ForceOverwrite: existing files are left alone unless the
# user asks to overwrite. Community plugins are listed as enabled but not
# downloaded — Obsidian needs the user to install them from Settings on first
# launch.
# ------------------------------------------------------------

Write-Section "Obsidian per-vault settings"

function Write-ObsidianSettingsFile {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $fileName = Split-Path -Leaf $Path
    if ((Test-Path -Path $Path) -and (-not $ForceOverwrite)) {
        Write-Host "  $fileName : skipped (exists, pass -ForceOverwrite to replace)" -ForegroundColor DarkGray
        return
    }

    Set-Content -Path $Path -Value $Content -Encoding UTF8 -NoNewline
    Write-Host "  $fileName : written" -ForegroundColor Cyan
}

$ObsidianPath = Join-Path $VaultPath ".obsidian"
[void](New-Item -ItemType Directory -Force -Path $ObsidianPath)

$AppJson = @'
{
  "newLinkFormat": "relative",
  "userIgnoreFilters": [".git"]
}
'@

$TemplatesJson = @'
{
  "folder": "System/Templates"
}
'@

$DailyNotesJson = @'
{
  "folder": "01 - Calendar/Daily",
  "format": "YYYY-MM-DD",
  "template": "System/Templates/Notes/Daily Note.md"
}
'@

$CommunityPluginsJson = @'
["dataview", "templater-obsidian"]
'@

Write-ObsidianSettingsFile -Path (Join-Path $ObsidianPath "app.json") -Content $AppJson
Write-ObsidianSettingsFile -Path (Join-Path $ObsidianPath "templates.json") -Content $TemplatesJson
Write-ObsidianSettingsFile -Path (Join-Path $ObsidianPath "daily-notes.json") -Content $DailyNotesJson
Write-ObsidianSettingsFile -Path (Join-Path $ObsidianPath "community-plugins.json") -Content $CommunityPluginsJson

# ------------------------------------------------------------
# Completion message
# ------------------------------------------------------------

Write-Host ""
Write-Host "Vault created." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open the vault in Obsidian: File -> Open Vault -> $VaultPath"
Write-Host "  2. Install community plugins (one-time):"
Write-Host "       Settings -> Community plugins -> Browse"
Write-Host "       Install and enable: Dataview, Templater"
Write-Host "       (community-plugins.json already lists them as enabled.)"
Write-Host "  3. Read Obsidian-AI-User-Guide.md to learn the day-to-day workflow."
Write-Host "       (Vault-Guide.md and Obsidian-AI-Workflow-Guide.md cover orientation and rationale.)"
Write-Host "  4. Create your first project:"
Writ