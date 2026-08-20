param([ValidateSet('synth','flow')] [string]$Stage = 'synth')
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
$command = "source /OpenROAD-flow-scripts/env.sh >/dev/null; make -C /OpenROAD-flow-scripts/flow DESIGN_CONFIG=/design/openroad/config.mk $target"
& docker run --rm @mounts openroad/orfs:latest bash -lc $command
if ($LASTEXITCODE -ne 0) { throw "OpenROAD $Stage failed with exit code $LASTEXITCODE" }
