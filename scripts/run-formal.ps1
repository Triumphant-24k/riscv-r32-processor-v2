param([string]$Image='openroad/orfs:v2-compatible-20260818')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
& docker run --rm -v "${projectRoot}:/design" -w /design $Image `
    bash -lc 'rm -rf build/formal/cpu_properties; sby -f -d build/formal/cpu_properties formal/cpu_properties.sby'
if($LASTEXITCODE-ne 0){throw "Formal property check failed with exit code $LASTEXITCODE"}
