$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$windowsPath = $projectRoot -replace '\\', '/'
$wslProjectRoot = (& wsl.exe -d Ubuntu-22.04 -- wslpath -a $windowsPath).Trim()
if (-not $wslProjectRoot) {
    throw 'Could not translate the project path for WSL.'
}

$command = @"
cd '$wslProjectRoot'
exec docker run --rm \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "`$(pwd):/design" \
  -v "`$(pwd)/build/openroad/results:/OpenROAD-flow-scripts/flow/results" \
  -v "`$(pwd)/build/openroad/logs:/OpenROAD-flow-scripts/flow/logs" \
  -v "`$(pwd)/build/openroad/reports:/OpenROAD-flow-scripts/flow/reports" \
  -v "`$(pwd)/build/openroad/objects:/OpenROAD-flow-scripts/flow/objects" \
  openroad/orfs:v2-compatible-20260818 bash -lc \
  'source /OpenROAD-flow-scripts/env.sh >/dev/null; make -C /OpenROAD-flow-scripts/flow DESIGN_CONFIG=/design/openroad/config.mk FLOW_VARIANT=compat gui_final'
"@

& wsl.exe -d Ubuntu-22.04 -- bash -lc $command
if ($LASTEXITCODE -ne 0) {
    throw "OpenROAD GUI exited with code $LASTEXITCODE"
}
