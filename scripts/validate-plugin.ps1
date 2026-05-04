<#
.SYNOPSIS
    Validate plugin-mh metadata, Codex adapter prompts, and guardrail docs.

.EXAMPLE
    .\scripts\validate-plugin.ps1
#>

[CmdletBinding()]
param()

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

$skillDirs = Get-ChildItem -Path (Join-Path $root 'skills') -Directory | Sort-Object Name
$agentFiles = Get-ChildItem -Path (Join-Path $root 'agents') -Filter '*.md' -File -ErrorAction SilentlyContinue
$promptFiles = Get-ChildItem -Path (Join-Path $root 'codex/prompts') -Filter '*.md' -File | Sort-Object Name

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

if ($errors.Count -gt 0) {
    Write-Host "plugin-mh validation failed:" -ForegroundColor Red
    foreach ($errorMessage in $errors) {
        Write-Host "  - $errorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host "plugin-mh validation passed." -ForegroundColor Green
Write-Host "Skills: $($skillDirs.Count) | Agents: $($agentFiles.Count) | Codex prompts: $($promptFiles.Count) | Guardrails: $($guardrailFiles.Count)"
