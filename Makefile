QUESTA := powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-questa.ps1
SYNTH_RTL := rtl/alu.v rtl/branch_unit.v rtl/control_unit.v rtl/cpu_core.v \
	rtl/immediate_generator.v rtl/load_store_unit.v rtl/register_file.v

.PHONY: lint unit-test core-test isa-test test clean
lint:
	@echo "Verilator is required: verilator --lint-only -Wall --top-module cpu_core $(SYNTH_RTL)"
	verilator --lint-only -Wall --top-module cpu_core $(SYNTH_RTL)

unit-test:
	$(QUESTA) unit

core-test:
	$(QUESTA) core

isa-test:
	@echo "Official riscv-arch-test integration requires a RISC-V GNU toolchain and Sail reference model."
	@echo "No official architectural result is claimed by this project."
	@false

test: unit-test core-test

clean:
	powershell -NoProfile -Command "if (Test-Path work) { Remove-Item -LiteralPath work -Recurse -Force }; Remove-Item transcript,vsim.wlf -Force -ErrorAction SilentlyContinue"
