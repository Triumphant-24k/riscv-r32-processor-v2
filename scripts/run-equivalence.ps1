param([string]$Image='openroad/orfs:v2-compatible-20260818')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'build/formal')|Out-Null
& docker run --rm -v "${projectRoot}:/design" -w /design $Image `
    bash -lc 'yosys -ql build/formal/equivalence.log formal/equivalence.ys'
if($LASTEXITCODE-ne 0){throw "Yosys equivalence failed with exit code $LASTEXITCODE"}
