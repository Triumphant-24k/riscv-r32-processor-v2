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

The optional continuation completed floorplanning and placement, then failed
during CTS with `child killed: illegal instruction`. This is a container/host
CPU instruction compatibility failure, not a reported RTL, timing, or routing
failure. Because CTS did not complete, no final hold, routing, IR-drop, or GDS
result is claimed. Generated artifacts and logs are in `build/openroad/`.
Images under `docs/openroad-results/` remain legacy results for the old subset.

An educational OpenROAD run is not foundry signoff. Tapeout also requires
signoff DRC/LVS, antenna closure, extracted timing, power integrity, package,
ESD, and manufacturing verification.
