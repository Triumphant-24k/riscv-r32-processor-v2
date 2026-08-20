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

## Result status

The updated flow was not executed on 2026-08-20 because `openroad`, `yosys`, and
OpenROAD Flow Scripts were not installed. There are no current-v2 area, slack,
utilization, routing, power, IR-drop, or GDS results. Images under
`docs/openroad-results/` are preserved legacy results for the earlier subset.

An educational OpenROAD run is not foundry signoff. Tapeout also requires
signoff DRC/LVS, antenna closure, extracted timing, power integrity, package,
ESD, and manufacturing verification.
