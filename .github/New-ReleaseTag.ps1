<# 
Usage:
  .\New-ReleaseTag.ps1 -Tag v1.0.0 [-Message "Release v1.0.0"] [-Branch main] [-AllowDirty]
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Tag,
    [string]$Message = "Release $Tag",
    [string]$Branch = "main",
    [switch]$AllowDirty
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-Git { param([Parameter(Mandatory=$true)][string[]]$Args)
git @Args | Write-Output
if ($LASTEXITCODE -ne 0) { throw "git $($Args -join ' ') failed with exit code $LASTEXITCODE" }
}

# sanity checks
Invoke-Git @('--version') | Out-Null
Invoke-Git @('rev-parse','--git-dir') | Out-Null

# ensure branch
$current = (Invoke-Git @('rev-parse','--abbrev-ref','HEAD')).Trim()
if ($current -ne $Branch) {
    Write-Host "Switching to branch '$Branch' (was '$current')..."
    Invoke-Git @('checkout', $Branch)
}

# update
Invoke-Git @('pull','--ff-only','origin', $Branch)

# clean working tree?
$dirty = (git status --porcelain)
if ($dirty -and -not $AllowDirty) {
    throw "Working tree has uncommitted changes. Commit/stash or pass -AllowDirty to proceed."
}

# create tag (fails if already exists)
Invoke-Git @('tag','-a', $Tag,'-m', $Message)

# push branch (optional but handy) and tag
Invoke-Git @('push','origin', $Branch)
Invoke-Git @('push','origin', $Tag)

Write-Host "✅ Created and pushed tag '$Tag' on '$Branch'."