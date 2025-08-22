<# 
Usage:
  .\ReTag.ps1 -Tag v1.0.0 [-Commit <sha>] [-Message "Release v1.0.0"]
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Tag,
    [string]$Commit,
    [string]$Message = "Release $Tag"
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-Git { param([Parameter(Mandatory=$true)][string[]]$Args)
git @Args | Write-Output
if ($LASTEXITCODE -ne 0) { throw "git $($Args -join ' ') failed with exit code $LASTEXITCODE" }
}

Invoke-Git @('--version') | Out-Null
Invoke-Git @('rev-parse','--git-dir') | Out-Null

# default commit = HEAD
if (-not $Commit) { $Commit = (git rev-parse HEAD).Trim() }
Invoke-Git @('rev-parse','--verify', "$Commit^{commit}") | Out-Null

# delete local tag if exists
if (git rev-parse -q --verify "refs/tags/$Tag" *> $null) {
    Write-Host "Deleting local tag $Tag..."
    Invoke-Git @('tag','-d', $Tag)
} else {
    Write-Host "Local tag $Tag not present; skipping local delete."
}

# delete remote tag (safe even if absent)
Write-Host "Deleting remote tag $Tag if present..."
git push origin ":refs/tags/$Tag"
if ($LASTEXITCODE -ne 0) { throw "Failed to delete remote tag $Tag" }

# recreate and push
Invoke-Git @('tag','-a', $Tag, $Commit, '-m', $Message)
Invoke-Git @('push','origin', $Tag)

Write-Host "✅ Re-tagged '$Tag' at $Commit and pushed to origin."