# OpenROAD Flow Scripts

The synthesis top is `cpu_core`. Simulation memory, wrappers, and testbenches
are excluded. `config.mk` targets `sky130hd`, begins at a 20 ns (50 MHz) clock,
and uses 35% core utilization. External instruction/data inputs and outputs use
a 4 ns boundary delay.

Run tests first. From Linux/WSL with OpenROAD Flow Scripts:

```sh
make test
make --file=/path/to/OpenROAD-flow-scripts/flow/Makefile \
  DESIGN_CONFIG="$PWD/openroad/config.mk"
```

The interface assumes combinational memory reads. Production integration
should add valid/ready or synchronous-memory stall logic and replace the
starter boundary constraints with measured SoC timing.

## Result status (2026-08-20)

The official `openroad/orfs:latest` Docker image was run with SKY130HD.
Simulation and Questa lint passed before synthesis.

| Metric | Result |
|---|---:|
| Yosys synthesis | PASS; 0 design-check problems |
| Mapped standard cells | 7,335 |
| Mapped cell area | 71,083.174 µm² |
| Sequential cells | 1,061 |
| Sequential area share | 37.35% |
| Floorplan die | 454.660 × 454.660 µm |
| Floorplan core utilization | 35.2% |
| Early setup WNS | +5.45 ns at 20 ns |
| Early estimated minimum period | 14.55 ns (68.74 MHz) |
| Early estimated power | 2.53 mW |

The complete compatibility run now passes synthesis, floorplanning, placement,
CTS, global routing, detailed routing, antenna repair, parasitic extraction,
timing, and GDS merge. Final results for the 20 ns constraint are:

| Result | Value |
|---|---:|
| Final setup WNS | +1.32 ns |
| Final hold slack | +0.50 ns |
| Setup / hold violations | 0 / 0 |
| Detailed-routing violations | 0 |
| Antenna net / pin violations | 0 / 0 |
| Placed design area | 81,482 µm² |
| Core utilization | 40% |
| Estimated total power | 5.39 mW |
| Worst VDD / VSS IR drop | 0.112 mV / 0.0946 mV |

The final layout is
`build/openroad/results/sky130hd/educational_rv32i/compat/6_final.gds`;
the same directory also contains final ODB, DEF, Verilog, SDC, and SPEF files.

The current ORFS `latest` image and the first older-image run crashed in CTS on
this non-AVX-512 host. The successful compatibility run therefore uses the
cached image tagged `openroad/orfs:v2-compatible-20260818` and `LEC_CHECK=0`.
This skips the flow's post-resize formal equivalence check; it does not mean
equivalence passed. RTL simulation and Yosys structural checks remain separate
checks. `scripts/run-openroad-docker.ps1` applies this workaround by default.
Images under `docs/openroad-results/` remain legacy results for the old subset.

To open the completed physical design interactively in OpenROAD through WSLg,
run this from Windows PowerShell after the flow has completed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\open-openroad-gui.ps1
```

Keep the PowerShell window open while using the GUI. Closing the OpenROAD
window returns control to PowerShell.

## GUI screenshots

The final routed processor database is shown with all routing layers enabled:

![Final routed cpu_core layout](../docs/openroad-v2-results/openroad-final-layout.png)

The setup and hold tabs show positive endpoint slack in the displayed paths:

| Setup timing | Hold timing |
|---|---|
| ![Setup timing report](../docs/openroad-v2-results/setup-timing-report.png) | ![Hold timing report](../docs/openroad-v2-results/hold-timing-report.png) |

The endpoint histogram provides a distribution view of setup slack. Formal
reported WNS/TNS and violation counts should be read from `6_finish.rpt` rather
than inferred from a cropped GUI view.

![Endpoint slack histogram](../docs/openroad-v2-results/endpoint-slack-histogram.png)

An educational OpenROAD run is not foundry signoff. Tapeout also requires
signoff DRC/LVS, antenna closure, extracted timing, power integrity, package,
ESD, and manufacturing verification.
