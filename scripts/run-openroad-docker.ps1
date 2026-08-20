param(
    [ValidateSet('synth','flow')] [string]$Stage = 'synth',
    [string]$Image = 'openroad/orfs:v2-compatible-20260818',
    [string]$Variant = 'compat',
    [bool]$DisableLecForAvx512Compatibility = $true
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$artifactRoot = Join-Path $projectRoot 'build/openroad'
foreach ($name in @('results','logs','reports','objects')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $artifactRoot $name) | Out-Null
}
$target = if ($Stage -eq 'synth') { 'synth' } else { '' }
$mounts = @(
    '-v', "${projectRoot}:/design",
    '-v', "$(Join-Path $artifactRoot 'results'):/OpenROAD-flow-scripts/flow/results",
    '-v', "$(Join-Path $artifactRoot 'logs'):/OpenROAD-flow-scripts/flow/logs",
    '-v', "$(Join-Path $artifactRoot 'reports'):/OpenROAD-flow-scripts/flow/reports",
    '-v', "$(Join-Path $artifactRoot 'objects'):/OpenROAD-flow-scripts/flow/objects"
)
$lec = if ($DisableLecForAvx512Compatibility) { 'LEC_CHECK=0 ' } else { '' }
$command = "source /OpenROAD-flow-scripts/env.sh >/dev/null; ${lec}make -C /OpenROAD-flow-scripts/flow DESIGN_CONFIG=/design/openroad/config.mk FLOW_VARIANT=$Variant $target"
& docker run --rm @mounts $Image bash -lc $command
if ($LASTEXITCODE -ne 0) { throw "OpenROAD $Stage failed with exit code $LASTEXITCODE" }
