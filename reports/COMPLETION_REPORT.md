# Upgrade completion report — 2026-08-20

## Outcome

The maintained core is now a stallable non-pipelined RV32I educational
processor with separate instruction/data request-response interfaces. All local
simulation suites and formal safety properties pass. The revised RTL completed
the SKY130HD RTL-to-GDS flow. Official ACT4 tests were not run, and logical
equivalence was attempted but not established.

## Verification evidence

| Stage | Command | Status | Evidence |
|---|---|---|---|
| Baseline | `scripts/run-questa.ps1 all` | PASS | unit 46, original core 40 |
| Final simulation | `scripts/run-questa.ps1 all` | PASS | unit 46; directed 176/63; wait modes 3; generated 300 |
| Lint | `make lint` / `verilator` | NOT RUN | executable unavailable |
| Official RV32I | `scripts/run-act4.ps1` | NOT RUN | missing Bundle/toolchain/Sail; adapter incomplete |
| Formal properties | `scripts/run-formal.ps1` | PASS | 8 assertions, SBY/ABC PDR |
| Equivalence | `scripts/run-equivalence.ps1` | FAIL | 1,208 unproven `$equiv` cells |
| OpenROAD synthesis | `scripts/run-openroad-docker.ps1 synth` | PASS | zero Yosys check problems |
| OpenROAD full flow | `scripts/run-openroad-docker.ps1 flow` | PASS | final GDS generated |

Directed coverage includes every README instruction, arithmetic edge values,
signed/unsigned comparisons, shift edges/masking, immediate extremes, every
byte/halfword lane, exact strobes, neighboring-byte preservation, every branch
taken/not-taken, forward/backward flow, jump links, misalignment suppression,
invalid encodings, x0/NOP, FENCE, ECALL/EBREAK, terminal traps, and reset.

The deterministic generated suite passed 300 ALU instructions against its
reference model with seed `52a1c0de`. The wait suite passed the same program with
zero, fixed, and pseudo-random delay/backpressure, accepting one store per mode.

## Latest OpenROAD metrics

| Item | Result |
|---|---:|
| Synthesis / Yosys check | PASS / 0 problems |
| Cells / mapped area | 8,558 / 72,087.888 µm² |
| Sequential cells | 1,175 |
| CTS | PASS; 1 clock, 1,175 sinks |
| Die | 457.835 × 457.835 µm |
| Final area / utilization | 82,565 µm² / 40% |
| Setup WNS / violations | +9.08 ns / 0 |
| Hold WNS / violations | +0.47 ns / 0 |
| Minimum period / Fmax | 10.92 ns / 91.61 MHz |
| Detailed-route violations | 0 |
| Antenna net / pin violations | 0 / 0 |
| Max slew / capacitance violations | 13 / 5 |
| Estimated power | 10.7 mW |

Final ODB, DEF, netlist, SDC, SPEF, and GDS are named `6_final.*` under
`build/openroad/results/sky130hd/educational_rv32i/handshake/`. No new IR-drop
result was present, so no old or inferred number is claimed. ORFS LEC was
disabled for the documented host incompatibility; independent equivalence
failed.

## File summary and limitations

- Modified: maintained core/wrapper/memory/register file, tests, scripts,
  Makefile, SDC, README, implementation plan, and OpenROAD documentation.
- Created: formal and ACT4 integrations, generated/wait tests, result reports,
  completion report, and current OpenROAD images.
- Moved: old `src/*.v` to `legacy/rtl/`, old `tb/*.v` to `legacy/tb/`, and
  historical diagrams/layout screenshots to `legacy/docs/`.

Official tests remain NOT RUN; equivalence is not established; STA retains 13
slew and 5 capacitance violations; caches, pipeline, privilege, CSRs, interrupts,
and recoverable traps are absent. The layout lacks foundry signoff DRC/LVS,
multi-corner closure, full integrity, package, ESD, and manufacturing checks.

Safe wording: “Designed and verified a stallable non-pipelined educational
RV32I processor; independently directed-tested all 40 base instructions, proved
safety properties, and completed an educational SKY130HD OpenROAD RTL-to-GDS
flow with zero setup, hold, detailed-route, and antenna violations.”

Do not say “passed official RV32I tests,” “RV32I compliant,” “equivalence
proven,” “timing fully clean,” or “tapeout-ready.” No Git commit, push, branch,
pull request, or GitHub modification was performed.
