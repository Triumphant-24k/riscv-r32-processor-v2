# Implementation plan and status

1. **Inspect and baseline** — complete. Original RTL, text tests, scripts,
   documentation, and OpenROAD configuration were reviewed; binary artifacts
   and screenshots were inventoried and preserved.
2. **Refactor safely** — complete. Maintained RTL is under `rtl/`; legacy RTL
   remains under `src/` for comparison.
3. **Complete RV32I datapath/decode** — complete for the base instructions in
   the README.
4. **Memory interface and traps** — complete for immediate-response memories,
   four byte strobes, illegal instructions, alignment, ECALL, and EBREAK.
5. **Self-checking verification** — directed unit/core tests complete. Random
   generation and official architectural tests remain future work.
6. **Lint and regression** — Questa compilation/regression pass. Verilator lint
   is pending because Verilator is unavailable.
7. **OpenROAD physical design** — complete for the educational SKY130HD flow.
   Yosys synthesis, floorplanning, placement, CTS, global and detailed routing,
   antenna repair, parasitic extraction, timing analysis, IR-drop analysis, and
   GDS generation completed. Final reports show zero setup, hold, detailed-route,
   and antenna violations. The final `6_final.gds` and OpenROAD GUI launcher are
   available under the documented `build/openroad/` flow. Post-resize LEC was
   skipped with `LEC_CHECK=0` because the available ORFS binaries require an
   unsupported AVX-512 instruction on this laptop; foundry signoff and tapeout
   remain outside this educational project.
8. **Documentation** — complete for the current implementation. Architecture,
   interfaces, examples, limitations, final OpenROAD metrics, GUI instructions,
   and physical-layout screenshots are documented.
