QUESTA := powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-questa.ps1
SYNTH_RTL := rtl/alu.v rtl/branch_unit.v rtl/control_unit.v rtl/cpu_core.v \
	rtl/immediate_generator.v rtl/load_store_unit.v rtl/register_file.v

.PHONY: lint unit-test core-test memory-wait-test generated-test isa-test formal equivalence test openroad-synth openroad-flow clean
lint:
	@echo "Verilator is required: verilator --lint-only -Wall --top-module cpu_core $(SYNTH_RTL)"
	verilator --lint-only -Wall --top-module cpu_core $(SYNTH_RTL)

unit-test:
	$(QUESTA) unit

core-test:
	$(QUESTA) core

memory-wait-test:
	$(QUESTA) memory

generated-test:
	$(QUESTA) generated

isa-test:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-act4.ps1

formal:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-formal.ps1

equivalence:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-equivalence.ps1

test: unit-test core-test memory-wait-test generated-test

openroad-synth:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-openroad-docker.ps1 synth

openroad-flow:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-openroad-docker.ps1 flow

clean:
	powershell -NoProfile -Command "if (Test-Path work) { Remove-Item -LiteralPath work -Recurse -Force }; Remove-Item transcript,vsim.wlf -Force -ErrorAction SilentlyContinue"
