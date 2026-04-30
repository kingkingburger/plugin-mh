<#
.SYNOPSIS
    plugin-mh 의 Codex 슬래시 커맨드 프롬프트를 ~\.codex\prompts\ 에 설치한다.

.DESCRIPTION
    기본 동작: codex/prompts/*.md 각각에 대해 ~/.codex/prompts/<name>.md 심볼릭 링크 생성.
    저장소 업데이트 시 Codex 측 프롬프트도 자동 반영된다.

    -Copy 옵션 사용 시: 링크 대신 파일 복사. 권한 부족(개발자 모드 비활성)으로 링크가 안 만들어질 때 폴백.

.PARAMETER Copy
    심볼릭 링크 대신 파일을 복사한다.

.PARAMETER Force
    기존 동일 이름 파일/링크가 있으면 덮어쓴다.

.EXAMPLE
    .\codex\install.ps1
    .\codex\install.ps1 -Copy
    .\codex\install.ps1 -Force
#>

[CmdletBinding()]
param(
    [switch]$Copy,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$promptsSrc = Join-Path $scriptDir 'prompts'
$promptsDst = Join-Path $env:USERPROFILE '.codex\prompts'

if (-not (Test-Path $promptsSrc)) {
    Write-Error "Source not found: $promptsSrc"
    exit 1
}

if (-not (Test-Path $promptsDst)) {
    Write-Host "Creating $promptsDst"
    New-Item -ItemType Directory -Path $promptsDst -Force | Out-Null
}

$files = Get-ChildItem $promptsSrc -Filter *.md
$installed = 0
$skipped = 0
$failed = 0

foreach ($file in $files) {
    $dstPath = Join-Path $promptsDst $file.Name

    if (Test-Path $dstPath) {
        if ($Force) {
            Remove-Item $dstPath -Force
        } else {
            Write-Host "[skip] $($file.Name) already exists (use -Force to overwrite)" -ForegroundColor DarkYellow
            $skipped++
            continue
        }
    }

    try {
        if ($Copy) {
            Copy-Item $file.FullName $dstPath
            Write-Host "[copy] $($file.Name)" -ForegroundColor Green
        } else {
            New-Item -ItemType SymbolicLink -Path $dstPath -Target $file.FullName | Out-Null
            Write-Host "[link] $($file.Name)" -ForegroundColor Green
        }
        $installed++
    } catch {
        Write-Host "[fail] $($file.Name): $_" -ForegroundColor Red
        Write-Host "        Hint: 심볼릭 링크 권한이 없으면 -Copy 옵션으로 재실행하거나" -ForegroundColor DarkYellow
        Write-Host "        Windows 설정 > 개발자용 > '개발자 모드' 활성화 후 재시도." -ForegroundColor DarkYellow
        $failed++
    }
}

Write-Host ""
Write-Host "Installed: $installed | Skipped: $skipped | Failed: $failed"
Write-Host "Target:    $promptsDst"
Write-Host ""
Write-Host "Codex CLI를 재시작하면 다음 슬래시 커맨드가 활성화됩니다:" -ForegroundColor Cyan
Get-ChildItem $promptsDst -Filter *.md | ForEach-Object { "  /$([System.IO.Path]::GetFileNameWithoutExtension($_.Name))" }

if ($failed -gt 0) { exit 1 }
