param([ValidateSet('unit','core','all')] [string]$Suite = 'all')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$rtl = @(
    'rtl/alu.v','rtl/immediate_generator.v','rtl/register_file.v','rtl/branch_unit.v',
    'rtl/load_store_unit.v','rtl/control_unit.v','rtl/cpu_core.v','rtl/simulation_memory.v','rtl/cpu_sim_top.v'
)
Push-Location $projectRoot
try {
    if (Test-Path work) { Remove-Item -LiteralPath work -Recurse -Force }
    & vlib work
    if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    & vlog -sv @rtl
    if ($LASTEXITCODE -ne 0) { throw 'RTL compilation failed' }
    if ($Suite -in @('unit','all')) {
        & vlog -sv tb/unit/unit_tb.sv
        if ($LASTEXITCODE -ne 0) { throw 'unit test compilation failed' }
        & vsim -c unit_tb -do 'run -all; quit -f'
        if ($LASTEXITCODE -ne 0) { throw 'unit regression failed' }
    }
    if ($Suite -in @('core','all')) {
        & vlog -sv tb/core/core_tb.sv
        if ($LASTEXITCODE -ne 0) { throw 'core test compilation failed' }
        & vsim -c core_tb -do 'run -all; quit -f'
        if ($LASTEXITCODE -ne 0) { throw 'core regression failed' }
    }
} finally { Pop-Location }
