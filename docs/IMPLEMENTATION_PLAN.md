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
7. **OpenROAD** — configuration updated; execution pending because OpenROAD and
   Yosys are unavailable.
8. **Documentation** — architecture, interfaces, examples, and limitations are
   documented.
