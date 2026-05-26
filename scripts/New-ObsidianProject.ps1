<#
.SYNOPSIS
Creates a new Obsidian project folder from the project template, optionally
initialising or cloning a git repository at the project root.

.DESCRIPTION
This script copies the relevant Work or Personal project template (from
System\Templates\Projects\<Type>) into 02 - Projects\<Type>\<SafeProjectName>,
then fills in starter values for project metadata.

Layout produced:
  <Project>\
    .gitignore                 (repo root)
    AGENTS.md                  (auto-discovery for Codex / AGENTS.md-aware agents)
    CLAUDE.md                  (auto-load stub for Claude Code → references _meta\CLAUDE.md)
    README.md                  (repo-facing stub — only in Init mode)
    _meta\
      README.md, CLAUDE.md, AI-Memory.md, PRD.md, Scope.md, Tasks.md,
      Handover.md, Decisions\, Risks-Issues\, Plans\, Slices\, Specs\,
      References\, AI-Sessions\, Meetings\, Assets\, Development\ (Work only)

Repo modes:
  - None  (default): just copy the template. .gitignore is left at the root
            so a later `git init` will already have it. No git is run.
  - Init : copy the template, stub a minimal root README.md, run `git init`
            at the project root.
  - Clone: `git clone <RepoUrl>` into the project folder first, then overlay
            the _meta\ template into the cloned repo. The template's
            .gitignore is placed at _meta\.gitignore so the cloned repo's
            root .gitignore is not disturbed.

.EXAMPLE
.\New-ObsidianProject.ps1

.EXAMPLE
.\New-ObsidianProject.ps1 -ProjectName "ServiceNow SMS Suppression" -ProjectType Work -RepoMode Init

.EXAMPLE
.\New-ObsidianProject.ps1 `
    -ProjectName "Pwd Reset Gateway" `
    -ProjectType Work `
    -RepoMode Clone `
    -RepoUrl "https://github.com/example/pwd-reset-gateway.git" `
    -Owner "your.name" `
    -Area "Azure" `
    -Status "Planning" `
    -TargetDate "2026-06-30"

.NOTES
Vault path resolution order:
  1. -VaultPath argument (prompted with this as the default; user can edit).
  2. Auto-detected from the script location (assumes the script lives at
     <vault>\System\Scripts\New-ObsidianProject.ps1).
  3. If neither applies, the script asks you to type a path. No silent
     fallback — nothing is created until you've confirmed where the vault is.
Existing projects are not overwritten.
#>

param (
    # Vault path. If omitted, the script auto-detects from its own location
    # (System\Scripts\ inside a vault). If that also fails, prompts for an
    # explicit path — there is no silent fallback to a default location.
    [string]$VaultPath = "",

    [string]$ProjectName,

    [ValidateSet("Work", "Personal")]
    [string]$ProjectType,

    [ValidateSet("None", "Init", "Clone")]
    [string]$RepoMode = "None",

    [string]$RepoUrl,

    [string]$Owner,

    [string]$Area,

    [string]$Status,

    [string]$TargetDate,

    # Skills selection. Accepts:
    #   None     - import nothing
    #   Default  - curated set (kickoff, wrap-up, new-session-log)
    #   All      - every skill in the library
    #   Custom   - interactive picker
    #   comma-separated list (e.g. "kickoff,wrap-up") - import exactly those
    [string]$Skills = "",

    [switch]$OpenInExplorer
)

# ------------------------------------------------------------
# Resolve default vault path
#
# Priority:
#   1. -VaultPath argument (used as default, user can still override)
#   2. Auto-detected from script location (script lives in <vault>\System\Scripts\)
#   3. No default — the user is asked to type a path; nothing is assumed.
# ------------------------------------------------------------

$VaultPathDefault = $VaultPath
$VaultPathDefaultSource = ""

if ([string]::IsNullOrWhiteSpace($VaultPathDefault)) {
    # If this script is in <vault>\System\Scripts\, vault root is two parents up.
    if ($PSScriptRoot) {
        try {
            $candidate = (Get-Item $PSScriptRoot).Parent.Parent.FullName
            if (Test-Path -Path (Join-Path $candidate "CLAUDE.md")) {
                $VaultPathDefault = $candidate
                $VaultPathDefaultSource = "auto-detected from script location"
            }
        } catch {}
    }
    # If auto-detect failed, leave $VaultPathDefault empty so the prompt below
    # forces the user to type a path. No silent fallback — we never assume
    # where the vault is.
}

# ------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------

function Read-RequiredValue {
    param ([string]$PromptText, [string]$CurrentValue)

    if (-not [string]::IsNullOrWhiteSpace($CurrentValue)) {
        return $CurrentValue.Trim()
    }

    do {
        $Value = Read-Host $PromptText
        if ([string]::IsNullOrWhiteSpace($Value)) {
            Write-Host "This value is required." -ForegroundColor Yellow
        }
    } while ([string]::IsNullOrWhiteSpace($Value))

    return $Value.Trim()
}

function Read-OptionalValue {
    param ([string]$PromptText, [string]$CurrentValue, [string]$DefaultValue)

    if (-not [string]::IsNullOrWhiteSpace($CurrentValue)) {
        return $CurrentValue.Trim()
    }

    $PromptWithDefault = if (-not [string]::IsNullOrWhiteSpace($DefaultValue)) {
        "$PromptText [$DefaultValue]"
    } else {
        $PromptText
    }

    $Value = Read-Host $PromptWithDefault
    if ([string]::IsNullOrWhiteSpace($Value)) { return $DefaultValue }
    return $Value.Trim()
}

function Read-ProjectType {
    param ([string]$CurrentValue)

    # PowerShell -eq is case-insensitive. Return the canonical case so
    # filesystem paths and downstream output are consistent regardless
    # of what the user typed.
    if ($CurrentValue -eq "Work")     { return "Work" }
    if ($CurrentValue -eq "Personal") { return "Personal" }

    do {
        $Value = Read-Host "Project type: Work or Personal [Work]"
        if ([string]::IsNullOrWhiteSpace($Value)) { return "Work" }
        $Value = $Value.Trim()
        if ($Value -eq "Work")     { return "Work" }
        if ($Value -eq "Personal") { return "Personal" }
        Write-Host "Please enter either Work or Personal." -ForegroundColor Yellow
    } while ($true)
}

function Read-RepoMode {
    param ([string]$CurrentValue)

    # Normalise case as for Read-ProjectType.
    if ($CurrentValue -eq "None")  { return "None" }
    if ($CurrentValue -eq "Init")  { return "Init" }
    if ($CurrentValue -eq "Clone") { return "Clone" }

    do {
        $Value = Read-Host "Repo mode: None (notes only) / Init (git init new repo) / Clone (clone existing repo) [None]"
        if ([string]::IsNullOrWhiteSpace($Value)) { return "None" }
        $Value = $Value.Trim()
        if ($Value -eq "None")  { return "None" }
        if ($Value -eq "Init")  { return "Init" }
        if ($Value -eq "Clone") { return "Clone" }
        Write-Host "Please enter None, Init, or Clone." -ForegroundColor Yellow
    } while ($true)
}

function Get-AvailableSkills {
    param ([string]$SkillsLibraryPath)

    if (-not (Test-Path -Path $SkillsLibraryPath)) { return @() }

    Get-ChildItem -Path $SkillsLibraryPath -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } |
        Select-Object -ExpandProperty Name |
        Sort-Object
}

function Read-SkillsSelection {
    param ([string]$CurrentValue)

    if (-not [string]::IsNullOrWhiteSpace($CurrentValue)) {
        return $CurrentValue.Trim()
    }

    Write-Host ""
    Write-Host "Skills to import (helper skills like /kickoff, /wrap-up, /new-session-log):"
    Write-Host "  None     - import nothing"
    Write-Host "  Default  - curated set: kickoff, wrap-up, new-session-log (recommended)"
    Write-Host "  All      - every skill in the library"
    Write-Host "  Custom   - interactive picker"

    $Value = Read-Host "Skills [Default]"
    if ([string]::IsNullOrWhiteSpace($Value)) { return "Default" }
    return $Value.Trim()
}

function Resolve-SkillSelection {
    param (
        [string]$Selection,
        [string[]]$Available
    )

    $DefaultSet = @("kickoff", "wrap-up", "new-session-log", "handoff")

    if ($Selection -eq "None")    { return @() }
    if ($Selection -eq "Default") { return $DefaultSet | Where-Object { $_ -in $Available } }
    if ($Selection -eq "All")     { return $Available }

    if ($Selection -eq "Custom") {
        if ($Available.Count -eq 0) {
            Write-Warning "Skills library is empty."
            return @()
        }
        Write-Host ""
        Write-Host "Available skills (answer y/N for each):"
        $picked = @()
        foreach ($skill in $Available) {
            $marker = if ($skill -in $DefaultSet) { " (in default set)" } else { "" }
            $response = Read-Host "  $skill$marker [y/N]"
            if ($response.Trim().ToLower() -eq 'y') { $picked += $skill }
        }
        return $picked
    }

    # Comma-list — explicit names
    $names = $Selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $missing = $names | Where-Object { $_ -notin $Available }
    if ($missing) {
        throw "Unknown skill(s): $($missing -join ', '). Available: $($Available -join ', ')"
    }
    return $names
}

function Import-ProjectSkills {
    param (
        [string]$ProjectPath,
        [string]$SkillsLibraryPath,
        [string[]]$SkillNames,
        [string]$RepoMode
    )

    if ($SkillNames.Count -eq 0) {
        Write-Host "No skills imported." -ForegroundColor DarkGray
        return
    }

    $ClaudePath = Join-Path $ProjectPath ".claude\skills"
    $AgentsPath = Join-Path $ProjectPath ".agents\skills"

    New-Item -ItemType Directory -Force -Path $ClaudePath | Out-Null
    New-Item -ItemType Directory -Force -Path $AgentsPath | Out-Null

    foreach ($name in $SkillNames) {
        $src = Join-Path $SkillsLibraryPath $name
        if (-not (Test-Path -Path $src)) {
            Write-Warning "Skill '$name' not found at $src, skipping."
            continue
        }
        Copy-Item -Path $src -Destination $ClaudePath -Recurse -Force
        Copy-Item -Path $src -Destination $AgentsPath -Recurse -Force
    }

    Write-Host "Imported $($SkillNames.Count) skill(s): $($SkillNames -join ', ')" -ForegroundColor Cyan
    Write-Host "  -> $ClaudePath"
    Write-Host "  -> $AgentsPath"

    # Clone mode: the cloned repo's root .gitignore is left untouched. Add skill paths
    # to .git/info/exclude so they don't show in `git status`.
    if ($RepoMode -eq "Clone") {
        $ExcludeFile = Join-Path $ProjectPath ".git\info\exclude"
        if (Test-Path -Path $ExcludeFile) {
            $existing = Get-Content -Path $ExcludeFile -Raw -ErrorAction SilentlyContinue
            if ($null -eq $existing) { $existing = "" }
            $linesToAdd = @()
            if ($existing -notmatch "(?m)^\.claude/skills/?\s*$") { $linesToAdd += ".claude/skills/" }
            if ($existing -notmatch "(?m)^\.agents/skills/?\s*$") { $linesToAdd += ".agents/skills/" }
            if ($linesToAdd.Count -gt 0) {
                Add-Content -Path $ExcludeFile -Value ""
                Add-Content -Path $ExcludeFile -Value "# Added by New-ObsidianProject.ps1 - helper skills are personal, not committed"
                $linesToAdd | ForEach-Object { Add-Content -Path $ExcludeFile -Value $_ }
                Write-Host "Updated .git/info/exclude with skill paths (local-only, not committed)." -ForegroundColor Cyan
            }
        }
    }
}

function Convert-ToSafeFileName {
    param ([string]$Name)
    return ($Name -replace '[\\/:*?"<>|]', '-').Trim()
}

function Test-GitAvailable {
    return [bool](Get-Command git -ErrorAction SilentlyContinue)
}

function Set-FrontmatterField {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Field,
        [Parameter(Mandatory = $true)][string]$Value
    )

    if (-not (Test-Path -Path $Path)) { return }

    $Content = Get-Content -Path $Path -Raw -Encoding UTF8

    # Only edit within the frontmatter block at the top of the file.
    if ($Content -notmatch '^\s*---\s*\r?\n([\s\S]*?)\r?\n---\s*\r?\n') { return }

    $Pattern = "(?m)^(?<field>$([regex]::Escape($Field))):.*$"
    $Replacement = "`${field}: $Value"

    $NewContent = [regex]::Replace($Content, $Pattern, $Replacement, 1)

    if ($NewContent -ne $Content) {
        Set-Content -Path $Path -Value $NewContent -Encoding UTF8
    }
}

function Set-BodyHeading {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$OldHeading,
        [Parameter(Mandatory = $true)][string]$NewHeading
    )

    if (-not (Test-Path -Path $Path)) { return }

    $Content = Get-Content -Path $Path -Raw -Encoding UTF8
    $Pattern = '(?m)^# ' + [regex]::Escape($OldHeading) + '\s*$'
    $NewContent = [regex]::Replace($Content, $Pattern, "# $NewHeading", 1)

    if ($NewContent -ne $Content) {
        Set-Content -Path $Path -Value $NewContent -Encoding UTF8
    }
}

function Set-StatusList {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][hashtable]$Values
    )

    if (-not (Test-Path -Path $Path)) { return }
    $Content = Get-Content -Path $Path -Raw -Encoding UTF8

    foreach ($Key in $Values.Keys) {
        $Pattern = "(?m)^- ${Key}:\s*$"
        $Replacement = "- ${Key}: $($Values[$Key])"
        $Content = [regex]::Replace($Content, $Pattern, $Replacement, 1)
    }

    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function Add-ProjectReferenceToBody {
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ProjectTitle
    )

    if (-not (Test-Path -Path $Path)) { return }
    $Content = Get-Content -Path $Path -Raw -Encoding UTF8

    if ($Content -match '(?m)^Project:\s*') { return }

    $Pattern = '(^# .+?\r?\n)'
    $NewContent = [regex]::Replace($Content, $Pattern, "`$1`r`nProject: [[$ProjectTitle]]`r`n", 1)

    Set-Content -Path $Path -Value $NewContent -Encoding UTF8
}

# ------------------------------------------------------------
# Prompt for values when not supplied
# ------------------------------------------------------------

Write-Host ""
Write-Host "Create new Obsidian project" -ForegroundColor Cyan
Write-Host "---------------------------" -ForegroundColor Cyan

# Show where the default vault path came from before prompting, so the user
# can tell at a glance whether the script auto-detected a vault or whether
# they need to type one in.
if (-not [string]::IsNullOrWhiteSpace($VaultPath)) {
    # User passed -VaultPath explicitly — prompt with their value as default.
    $VaultPath = Read-OptionalValue -PromptText "Vault path" -CurrentValue "" -DefaultValue $VaultPath
} elseif (-not [string]::IsNullOrWhiteSpace($VaultPathDefault)) {
    # Auto-detect succeeded — show the source and prompt with it as default.
    Write-Host ""
    Write-Host ("Vault path default: {0}" -f $VaultPathDefault) -ForegroundColor DarkGray
    Write-Host ("  ({0})" -f $VaultPathDefaultSource) -ForegroundColor DarkGray
    $VaultPath = Read-OptionalValue -PromptText "Vault path (press Enter to accept default, or type a different path)" -CurrentValue "" -DefaultValue $VaultPathDefault
} else {
    # No default available — require an explicit path. Keep asking until non-empty.
    Write-Host ""
    Write-Host "Script is not running from inside a vault and no -VaultPath was supplied." -ForegroundColor Yellow
    Write-Host "You must provide an explicit vault path." -ForegroundColor Yellow
    $VaultPath = Read-RequiredValue -PromptText "Vault path (full path to the existing vault folder)" -CurrentValue ""
}

$ProjectName = Read-RequiredValue -PromptText "Project name" -CurrentValue $ProjectName
$ProjectType = Read-ProjectType -CurrentValue $ProjectType
$RepoMode = Read-RepoMode -CurrentValue $RepoMode

if ($RepoMode -eq "Clone") {
    $RepoUrl = Read-RequiredValue -PromptText "Git repo URL to clone" -CurrentValue $RepoUrl
}

$Owner = Read-OptionalValue -PromptText "Owner" -CurrentValue $Owner -DefaultValue $env:USERNAME
$Area = Read-OptionalValue -PromptText "Area" -CurrentValue $Area -DefaultValue $ProjectType
$Status = Read-OptionalValue -PromptText "Status" -CurrentValue $Status -DefaultValue "Planning"
$TargetDate = Read-OptionalValue -PromptText "Target date (optional, YYYY-MM-DD format, e.g. 2026-06-30; press Enter to leave blank)" -CurrentValue $TargetDate -DefaultValue ""
$Skills = Read-SkillsSelection -CurrentValue $Skills

# ------------------------------------------------------------
# Resolve paths
# ------------------------------------------------------------

$SafeProjectName = Convert-ToSafeFileName -Name $ProjectName
$TemplatePath = Join-Path $VaultPath "System\Templates\Projects\$ProjectType"
$SkillsLibraryPath = Join-Path $VaultPath "04 - Resources\AI\Skills"
$ProjectPath = Join-Path $VaultPath "02 - Projects\$ProjectType\$SafeProjectName"
$MetaPath = Join-Path $ProjectPath "_meta"
$TodayIso = Get-Date -Format 'yyyy-MM-dd'

# Resolve which skills to import now so any errors surface before we create anything.
$AvailableSkills = Get-AvailableSkills -SkillsLibraryPath $SkillsLibraryPath
$SkillsToImport = Resolve-SkillSelection -Selection $Skills -Available $AvailableSkills

# ------------------------------------------------------------
# Validate
# ------------------------------------------------------------

if (-not (Test-Path -Path $VaultPath)) {
    throw "Vault path not found: $VaultPath"
}

if (-not (Test-Path -Path $TemplatePath)) {
    throw "Project template not found: $TemplatePath. Run Create-ObsidianAiVault.ps1 first."
}

if (Test-Path -Path $ProjectPath) {
    throw "Project already exists: $ProjectPath"
}

if ($RepoMode -in @("Init", "Clone") -and -not (Test-GitAvailable)) {
    throw "git was not found on PATH. Install git or use -RepoMode None."
}

# ------------------------------------------------------------
# Create project from template (per repo mode)
# ------------------------------------------------------------

# Track whether AGENTS.md at the project root was placed by this script.
# In clone mode, if the upstream repo already has its own AGENTS.md, this
# flips to true and we skip hydrating its frontmatter (we never mutate
# files owned by the upstream repo).
$AgentsMdFromUpstream = $false

switch ($RepoMode) {
    "Clone" {
        Write-Host "Cloning $RepoUrl into $ProjectPath ..." -ForegroundColor Cyan
        & git clone $RepoUrl $ProjectPath
        if ($LASTEXITCODE -ne 0) { throw "git clone failed (exit $LASTEXITCODE)." }

        # Overlay _meta/ from template
        $TemplateMeta = Join-Path $TemplatePath "_meta"
        Copy-Item -Path $TemplateMeta -Destination $ProjectPath -Recurse -Force

        # Copy template root-level files (AGENTS.md, .gitignore, etc.). For .gitignore
        # specifically, place at _meta\.gitignore to avoid clobbering the cloned repo's
        # root .gitignore. Other root files are copied to the project root unless the
        # cloned repo already has a file with that name (which we never overwrite).
        Get-ChildItem -Path $TemplatePath -File -Force | ForEach-Object {
            if ($_.Name -eq ".gitignore") {
                Copy-Item -Path $_.FullName -Destination (Join-Path $MetaPath ".gitignore") -Force
                Write-Host "Placed project .gitignore at _meta\.gitignore (cloned repo's root .gitignore preserved)." -ForegroundColor Yellow
            } else {
                $destAtRoot = Join-Path $ProjectPath $_.Name
                if (Test-Path -Path $destAtRoot) {
                    Write-Host "Skipped existing root file: $($_.Name) (cloned repo already has one)." -ForegroundColor DarkGray
                    if ($_.Name -eq "AGENTS.md") {
                        # Upstream owns this file. Tell the frontmatter
                        # hydration step below to leave it alone.
                        $script:AgentsMdFromUpstream = $true
                    }
                } else {
                    Copy-Item -Path $_.FullName -Destination $destAtRoot -Force
                    Write-Host "Copied template root file to project root: $($_.Name)" -ForegroundColor Cyan
                }
            }
        }
    }

    default {
        # None or Init — copy the full template tree (includes .gitignore at root, AGENTS.md, _meta/)
        Copy-Item -Path $TemplatePath -Destination $ProjectPath -Recurse
    }
}

# ------------------------------------------------------------
# Customise _meta/README.md
# ------------------------------------------------------------

$ReadmePath = Join-Path $MetaPath "README.md"

Set-BodyHeading -Path $ReadmePath -OldHeading "Project Name" -NewHeading $SafeProjectName

Set-FrontmatterField -Path $ReadmePath -Field "status" -Value $Status
Set-FrontmatterField -Path $ReadmePath -Field "area" -Value $Area
Set-FrontmatterField -Path $ReadmePath -Field "owner" -Value $Owner
Set-FrontmatterField -Path $ReadmePath -Field "start_date" -Value $TodayIso
if (-not [string]::IsNullOrWhiteSpace($TargetDate)) {
    Set-FrontmatterField -Path $ReadmePath -Field "target_date" -Value $TargetDate
}

Set-StatusList -Path $ReadmePath -Values @{
    "Status"      = $Status
    "Owner"       = $Owner
    "Start date"  = $TodayIso
    "Target date" = $TargetDate
    "Area"        = $Area
}

# ------------------------------------------------------------
# Fill `project:` frontmatter and body Project: reference across _meta/
# ------------------------------------------------------------

$FrontmatterFiles = @(
    "CLAUDE.md",
    "AI-Memory.md",
    "Decisions\README.md",
    "Decisions\0000-template.md",
    "Risks-Issues\README.md",
    "Risks-Issues\0000-template.md",
    "Plans\README.md",
    "Plans\0000-template.md",
    "Slices\README.md",
    "Slices\0000-template.md",
    "Specs\README.md",
    "Specs\0000-template.md",
    "References\README.md"
)

foreach ($Rel in $FrontmatterFiles) {
    Set-FrontmatterField -Path (Join-Path $MetaPath $Rel) -Field "project" -Value $SafeProjectName
}

# AGENTS.md lives at the project root (auto-discovered there by Codex et al), not inside _meta/.
# In clone mode, if the upstream repo already had an AGENTS.md, we left it alone above —
# do not mutate its frontmatter either.
if ($AgentsMdFromUpstream) {
    Write-Host "Left upstream AGENTS.md frontmatter unchanged (clone mode, file owned by upstream repo)." -ForegroundColor DarkGray
} else {
    Set-FrontmatterField -Path (Join-Path $ProjectPath "AGENTS.md") -Field "project" -Value $SafeProjectName
}

$BodyOnlyFiles = @(
    "PRD.md",
    "Scope.md",
    "Tasks.md",
    "Handover.md",
    "Development\Notes.md",
    "Development\Test-Cases.md",
    "AI-Sessions\_AI-Session-Index.md"
)

foreach ($Rel in $BodyOnlyFiles) {
    Add-ProjectReferenceToBody -Path (Join-Path $MetaPath $Rel) -ProjectTitle $SafeProjectName
}

# ------------------------------------------------------------
# Import skills
# ------------------------------------------------------------

Import-ProjectSkills `
    -ProjectPath $ProjectPath `
    -SkillsLibraryPath $SkillsLibraryPath `
    -SkillNames $SkillsToImport `
    -RepoMode $RepoMode

# ------------------------------------------------------------
# Repo-mode specific finishing steps
# ------------------------------------------------------------

switch ($RepoMode) {
    "Init" {
        $RootReadme = Join-Path $ProjectPath "README.md"
        if (-not (Test-Path -Path $RootReadme)) {
            $RootReadmeContent = @"
# $SafeProjectName

> Short description of what this project does.

---

This is the repository root. Working notes, decisions, AI context, and project metadata live in [``_meta/``](./_meta/).
"@
            Set-Content -Path $RootReadme -Value $RootReadmeContent -Encoding UTF8
            Write-Host "Stubbed root README.md."
        }

        Write-Host "Running git init in $ProjectPath ..." -ForegroundColor Cyan
        Push-Location $ProjectPath
        try {
            & git init | Out-Null
            if ($LASTEXITCODE -ne 0) { Write-Warning "git init returned exit $LASTEXITCODE." }
        } finally {
            Pop-Location
        }
    }

    "Clone" {
        Write-Host "Cloned repo left at $ProjectPath. _meta\ overlay applied; cloned repo's tracked files untouched." -ForegroundColor Cyan
    }

    default {
        # None — nothing to do
    }
}

# ------------------------------------------------------------
# Verify the auto-load chain
#
# Pure file-system checks — no agent involved. Catches the silent
# failure mode where a missing root CLAUDE.md or a broken
# @_meta/CLAUDE.md reference causes Claude Code to load nothing
# and the user only notices when the agent starts guessing at
# conventions.
# ------------------------------------------------------------

Write-Host ""
Write-Host "Verifying auto-load chain..." -ForegroundColor Cyan

$VerifyResults = @()

function Test-AutoLoadCheck {
    param (
        [string]$Label,
        [bool]$Passed,
        [string]$Detail
    )
    $script:VerifyResults += [pscustomobject]@{
        Label  = $Label
        Passed = $Passed
        Detail = $Detail
    }
}

$RootClaudePath = Join-Path $ProjectPath "CLAUDE.md"
$MetaClaudePath = Join-Path $MetaPath "CLAUDE.md"
$AgentsPath     = Join-Path $ProjectPath "AGENTS.md"

# 1. Root CLAUDE.md exists
Test-AutoLoadCheck -Label "Root CLAUDE.md exists" `
    -Passed (Test-Path -Path $RootClaudePath) `
    -Detail $RootClaudePath

# 2. Root CLAUDE.md contains @_meta/CLAUDE.md reference
if (Test-Path -Path $RootClaudePath) {
    $RootClaudeContent = Get-Content -Path $RootClaudePath -Raw -Encoding UTF8
    $HasMetaRef = $RootClaudeContent -match '(?m)^@_meta/CLAUDE\.md\s*$'
    Test-AutoLoadCheck -Label "Root CLAUDE.md references @_meta/CLAUDE.md" `
        -Passed $HasMetaRef `
        -Detail $(if ($HasMetaRef) { "reference found" } else { "MISSING - Claude Code will not load _meta/CLAUDE.md" })
} else {
    Test-AutoLoadCheck -Label "Root CLAUDE.md references @_meta/CLAUDE.md" -Passed $false -Detail "skipped (root CLAUDE.md missing)"
}

# 3. _meta/CLAUDE.md exists
Test-AutoLoadCheck -Label "_meta/CLAUDE.md exists" `
    -Passed (Test-Path -Path $MetaClaudePath) `
    -Detail $MetaClaudePath

# 4. AGENTS.md exists at project root
Test-AutoLoadCheck -Label "AGENTS.md exists at project root" `
    -Passed (Test-Path -Path $AgentsPath) `
    -Detail $AgentsPath

# Render results
$AllPassed = $true
foreach ($r in $VerifyResults) {
    if ($r.Passed) {
        Write-Host ("  [OK]   {0}" -f $r.Label) -ForegroundColor Green
    } else {
        Write-Host ("  [FAIL] {0} - {1}" -f $r.Label, $r.Detail) -ForegroundColor Red
        $AllPassed = $false
    }
}

if (-not $AllPassed) {
    if ($RepoMode -eq "Clone") {
        Write-Host ""
        Write-Host "Note: in Clone mode, the upstream repo's existing root files are not overwritten." -ForegroundColor Yellow
        Write-Host "If the upstream repo had its own AGENTS.md or CLAUDE.md, the missing references" -ForegroundColor Yellow
        Write-Host "above may be intentional. Otherwise, add the @_meta/CLAUDE.md line manually." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "Auto-load chain has gaps. Fresh sessions will not auto-load _meta/CLAUDE.md." -ForegroundColor Yellow
        Write-Host "Fix the failures above before starting work, or run /verify-context in your" -ForegroundColor Yellow
        Write-Host "first session to confirm what the agent can see." -ForegroundColor Yellow
    }
}

# ------------------------------------------------------------
# Completion message
# ------------------------------------------------------------

Write-Host ""
Write-Host "Created $ProjectType project ($RepoMode mode):" -ForegroundColor Green
Write-Host "  $ProjectPath"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. (One-time) Open '04 - Resources\AI\Prompts\Project-Bootstrap.md' and use"
Write-Host "     'Scaffold _meta/CLAUDE.md' (interview-style) to populate CLAUDE.md."
Write-Host "  2. (One-time) From the same Bootstrap file, use one of the 'Author PRD' prompts:"
Write-Host "       - Import (paste from another tool)"
Write-Host "       - Build (interview)"
Write-Host "       - Review (sanity-check an existing draft)"
if ($SkillsToImport.Count -gt 0) {
    Write-Host "  3. Start real work sessions with the imported skills:"
    foreach ($s in $SkillsToImport) { Write-Host "       /$s" }
    Write-Host "     (Skills are also paste-able as prompts from '04 - Resources\AI\Prompts\Project-Session-Kickoff.md' if you prefer.)"
} else {
    Write-Host "  3. When you start a real work session, use the prompts in"
    Write-Host "     '04 - Resources\AI\Prompts\Project-Session-Kickoff.md'."
}
if ($RepoMode -eq "Init") {
    Write-Host "  4. git add / commit at the project root when you're ready."
    Write-Host "     (Note: .claude/skills/ and .agents/skills/ are gitignored by default.)"
}
if ($RepoMode -eq "Clone") {
    Write-Host "  4. Review the repo and _meta\.gitignore; merge with the repo's root .gitignore"
    Write-Host "     if you want _meta entries committed. Skills are already excluded via"
    Write-Host "     .git/info/exclude (local-only, no commit needed)."
}
Write-Host ""

if ($OpenInExplorer) {
    Start-Process explorer.exe $ProjectPath
}
