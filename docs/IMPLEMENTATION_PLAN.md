# Implementation plan and status

Updated 2026-08-20 for the maintained handshake RTL.

1. **Inspection and baseline — complete.** All maintained and legacy sources,
   tests, scripts, documentation, and physical-design configuration were
   inspected. The original Questa baseline passed and is recorded.
2. **Directed verification — complete.** All 40 RV32I instructions are checked
   through the full core alongside alignment, decode, precise trap, reset, x0,
   byte-lane, strobe, and control-flow cases: 176 checks in 63 scenarios.
3. **Stallable memory architecture — complete.** Explicit request/response
   handshakes hold stalled requests stable, accept stores once, defer load
   write-back until response, and preserve precise traps. Zero-wait, fixed-delay,
   and random-delay/backpressure tests pass.
4. **Generated testing — complete.** 300 deterministic differential ALU tests
   pass with seed `52a1c0de`.
5. **Official tests — integration prepared; NOT RUN.** ACT4 is pinned at
   `4281ead674c5e36fe5f6b73b4a5854b25037c3cf`. Ruby Bundle, the GNU RISC-V
   toolchain, and Sail are missing; the DUT signature adapter also remains.
6. **Formal/equivalence — formal PASS; equivalence FAIL/not established.** Eight
   safety assertions were proved with SBY/ABC PDR. Independent Yosys equivalence
   left 1,208 unproven cells. ORFS LEC remains disabled for the AVX-512 host
   incompatibility. Equivalence is not claimed.
7. **OpenROAD software / physical design — complete.** The revised core
   completed synthesis, floorplan, placement, CTS, global and detailed routing,
   antenna repair, extraction, timing, fill, reporting, and merged GDS generation
   on SKY130HD. Routing, antenna, setup, and hold counts are zero. Thirteen slew
   and five capacitance violations remain documented. This is educational P&R,
   not foundry signoff or tapeout-ready.
8. **Legacy cleanup — complete.** Old `src/` RTL, top-level tests (including the
   empty `main_tb.v` placeholder), diagrams, and prior layout screenshots are
   preserved under `legacy/`.
9. **Documentation/reports — complete.** Architecture, interfaces, protocol
   diagrams, status wording, current images, metrics, and limitations now match
   the maintained implementation.

## Remaining work

- Install ACT4 dependencies, finish the DUT signature adapter, and execute the
  official RV32I architectural tests.
- Diagnose the failed independent equivalence proof or run ORFS LEC on a
  compatible machine.
- Close 13 slew and 5 capacitance violations and rerun P&R.
- Add foundry signoff DRC/LVS and multi-corner analysis only if the project moves
  beyond its educational scope.
