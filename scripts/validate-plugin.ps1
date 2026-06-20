<#
.SYNOPSIS
    Validate plugin-mh metadata, Codex adapter prompts, and guardrail docs.

.EXAMPLE
    .\scripts\validate-plugin.ps1
#>

[CmdletBinding()]
param(
    [switch]$Installed,
    [switch]$CodexInstalled,
    [switch]$ClaudeInstalled
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$errors = New-Object System.Collections.Generic.List[string]

function Add-ValidationError {
    param([string]$Message)
    $errors.Add($Message) | Out-Null
}

function Test-TextContains {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Message
    )

    $text = Get-Content -Encoding UTF8 -Raw -Path (Join-Path $root $Path)
    if ($text -notmatch $Pattern) {
        Add-ValidationError $Message
    }
}

function Test-InstalledCodexSurface {
    $skillsDst = if ($env:CODEX_SKILLS_DIR) {
        $env:CODEX_SKILLS_DIR
    } else {
        Join-Path $env:USERPROFILE '.codex\skills'
    }
    $promptsDst = if ($env:CODEX_PROMPTS_DIR) {
        $env:CODEX_PROMPTS_DIR
    } else {
        Join-Path $env:USERPROFILE '.codex\prompts'
    }

    if (-not (Test-Path -LiteralPath $skillsDst)) {
        Add-ValidationError "Installed Codex skills dir not found: $skillsDst"
        $installedSkillNames = @()
    } else {
        $installedSkillNames = Get-ChildItem -LiteralPath $skillsDst -Directory |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') } |
            Select-Object -ExpandProperty Name
    }

    if (-not (Test-Path -LiteralPath $promptsDst)) {
        Add-ValidationError "Installed Codex prompts dir not found: $promptsDst"
        $installedPromptNames = @()
    } else {
        $installedPromptNames = Get-ChildItem -LiteralPath $promptsDst -Filter '*.md' -File |
            Select-Object -ExpandProperty Name
    }

    foreach ($skill in $skillDirs) {
        if ($installedSkillNames -notcontains $skill.Name) {
            Add-ValidationError "Installed Codex skill missing: $($skill.Name)"
        }
    }

    foreach ($prompt in $promptFiles) {
        if ($installedPromptNames -notcontains $prompt.Name) {
            Add-ValidationError "Installed Codex prompt missing: $($prompt.Name)"
        }
    }
}

function Resolve-ClaudePluginPath {
    if ($env:CLAUDE_PLUGIN_DIR) {
        return $env:CLAUDE_PLUGIN_DIR
    }

    $cacheRoot = if ($env:CLAUDE_PLUGIN_CACHE_DIR) {
        $env:CLAUDE_PLUGIN_CACHE_DIR
    } else {
        Join-Path $env:USERPROFILE '.claude\plugins\cache\plugin-mh\plugin-mh'
    }

    if (Test-Path -LiteralPath $cacheRoot) {
        $versionSort = @{
            Expression = {
                try { [version]$_.Name } catch { [version]'0.0.0' }
            }
        }
        $inUse = Get-ChildItem -LiteralPath $cacheRoot -Directory |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName '.in_use') } |
            Sort-Object $versionSort |
            Select-Object -Last 1
        if ($inUse) {
            return $inUse.FullName
        }

        $latest = Get-ChildItem -LiteralPath $cacheRoot -Directory |
            Sort-Object $versionSort |
            Select-Object -Last 1
        if ($latest) {
            return $latest.FullName
        }
    }

    if ($env:CLAUDE_MARKETPLACE_DIR) {
        return $env:CLAUDE_MARKETPLACE_DIR
    }

    return Join-Path $env:USERPROFILE '.claude\plugins\marketplaces\plugin-mh'
}

function Get-JsonFile {
    param([string]$Path)

    Get-Content -Encoding UTF8 -Raw -Path $Path | ConvertFrom-Json
}

function Test-InstalledClaudeSurface {
    $pluginRoot = Resolve-ClaudePluginPath
    $manifestPath = Join-Path $pluginRoot '.claude-plugin\plugin.json'
    $skillsDst = Join-Path $pluginRoot 'skills'
    $agentsDst = Join-Path $pluginRoot 'agents'

    if (-not (Test-Path -LiteralPath $pluginRoot)) {
        Add-ValidationError "Installed Claude plugin dir not found: $pluginRoot"
        $installedSkillNames = @()
        $installedAgentNames = @()
    } else {
        if (-not (Test-Path -LiteralPath $manifestPath)) {
            Add-ValidationError "Installed Claude plugin manifest missing: $manifestPath"
        } else {
            $installedManifest = Get-JsonFile -Path $manifestPath
            if ($installedManifest.version -ne $sourcePluginManifest.version) {
                Add-ValidationError "Installed Claude plugin version mismatch: expected $($sourcePluginManifest.version), got $($installedManifest.version)"
            }
        }

        if (-not (Test-Path -LiteralPath $skillsDst)) {
            Add-ValidationError "Installed Claude skills dir not found: $skillsDst"
            $installedSkillNames = @()
        } else {
            $installedSkillNames = Get-ChildItem -LiteralPath $skillsDst -Directory |
                Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') } |
                Select-Object -ExpandProperty Name
        }

        if (-not (Test-Path -LiteralPath $agentsDst)) {
            Add-ValidationError "Installed Claude agents dir not found: $agentsDst"
            $installedAgentNames = @()
        } else {
            $installedAgentNames = Get-ChildItem -LiteralPath $agentsDst -Filter '*.md' -File |
                Select-Object -ExpandProperty Name
        }
    }

    foreach ($skill in $skillDirs) {
        if ($installedSkillNames -notcontains $skill.Name) {
            Add-ValidationError "Installed Claude skill missing: $($skill.Name)"
        }
    }

    foreach ($agent in $agentFiles) {
        if ($installedAgentNames -notcontains $agent.Name) {
            Add-ValidationError "Installed Claude agent missing: $($agent.Name)"
        }
    }
}

$skillDirs = Get-ChildItem -Path (Join-Path $root 'skills') -Directory | Sort-Object Name
$agentFiles = Get-ChildItem -Path (Join-Path $root 'agents') -Filter '*.md' -File -ErrorAction SilentlyContinue
$promptFiles = Get-ChildItem -Path (Join-Path $root 'codex/prompts') -Filter '*.md' -File | Sort-Object Name
$sourcePluginManifestPath = Join-Path $root '.claude-plugin/plugin.json'
if (-not (Test-Path -LiteralPath $sourcePluginManifestPath)) {
    Add-ValidationError 'Missing Claude plugin manifest: .claude-plugin/plugin.json'
    $sourcePluginManifest = [pscustomobject]@{ version = $null }
} else {
    $sourcePluginManifest = Get-JsonFile -Path $sourcePluginManifestPath
    if (-not $sourcePluginManifest.version) {
        Add-ValidationError 'Claude plugin manifest has no version: .claude-plugin/plugin.json'
    }
}

foreach ($skill in $skillDirs) {
    $skillPath = Join-Path $skill.FullName 'SKILL.md'
    if (-not (Test-Path $skillPath)) {
        Add-ValidationError "Missing SKILL.md: skills/$($skill.Name)"
        continue
    }

    $firstLine = Get-Content -Encoding UTF8 -Path $skillPath -TotalCount 1
    if ($firstLine -ne '---') {
        Add-ValidationError "Invalid frontmatter start: skills/$($skill.Name)/SKILL.md"
    }
}

$expectedPromptCount = $skillDirs.Count + $agentFiles.Count
if ($promptFiles.Count -ne $expectedPromptCount) {
    Add-ValidationError "Codex prompt count mismatch: expected $expectedPromptCount, got $($promptFiles.Count)"
}

$bannedCodexPatterns = @(
    'AskUserQuestion',
    'subagent_type',
    'Skill\(skill='
)

foreach ($prompt in $promptFiles) {
    $content = Get-Content -Encoding UTF8 -Raw -Path $prompt.FullName
    foreach ($pattern in $bannedCodexPatterns) {
        if ($content -match $pattern) {
            Add-ValidationError "Codex-only conversion leak in codex/prompts/$($prompt.Name): $pattern"
        }
    }
}

$guardrailFiles = @(
    'guardrails/README.md',
    'guardrails/core.md',
    'guardrails/laws.md',
    'guardrails/languages/typescript.md',
    'guardrails/languages/rust.md',
    'guardrails/languages/python.md',
    'guardrails/workflows/tdd.md',
    'guardrails/workflows/review.md'
)

foreach ($file in $guardrailFiles) {
    if (-not (Test-Path (Join-Path $root $file))) {
        Add-ValidationError "Missing guardrail file: $file"
    }
}

Test-TextContains -Path 'README.md' -Pattern 'Guardrails' -Message 'README.md does not mention Guardrails'
Test-TextContains -Path 'AGENTS.md' -Pattern 'guardrails/' -Message 'AGENTS.md does not mention guardrails/'
Test-TextContains -Path 'codex/README.md' -Pattern 'guardrails/' -Message 'codex/README.md does not mention guardrails/'
Test-TextContains -Path 'guardrails/languages/python.md' -Pattern '\bty\b' -Message 'Python guardrail does not mention ty'

$skillCount = $skillDirs.Count
Test-TextContains -Path 'README.md' -Pattern "$skillCount custom skills" -Message "README.md skill count is not $skillCount"
Test-TextContains -Path '.claude-plugin/marketplace.json' -Pattern "$skillCount custom skills" -Message "marketplace.json skill count is not $skillCount"

$claudeText = Get-Content -Encoding UTF8 -Raw -Path (Join-Path $root 'CLAUDE.md')
foreach ($skill in $skillDirs) {
    if ($claudeText -notmatch "(?m)^\| $([regex]::Escape($skill.Name)) \|") {
        Add-ValidationError "CLAUDE.md does not list skill: $($skill.Name)"
    }
}

if ($Installed) {
    $CodexInstalled = $true
    $ClaudeInstalled = $true
}

if ($CodexInstalled) {
    Test-InstalledCodexSurface
}

if ($ClaudeInstalled) {
    Test-InstalledClaudeSurface
}

if ($errors.Count -gt 0) {
    Write-Host "plugin-mh validation failed:" -ForegroundColor Red
    foreach ($errorMessage in $errors) {
        Write-Host "  - $errorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host "plugin-mh validation passed." -ForegroundColor Green
Write-Host "Skills: $($skillDirs.Count) | Agents: $($agentFiles.Count) | Codex prompts: $($promptFiles.Count) | Guardrails: $($guardrailFiles.Count)"
if ($CodexInstalled) {
    Write-Host "Installed Codex surface: skills $($skillDirs.Count) | prompts $($promptFiles.Count)"
}
if ($ClaudeInstalled) {
    Write-Host "Installed Claude surface: skills $($skillDirs.Count) | agents $($agentFiles.Count) | version $($sourcePluginManifest.version)"
}
