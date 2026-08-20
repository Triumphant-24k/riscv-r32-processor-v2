# Conservative 50 MHz starting constraint.
set clk_period 20.0
create_clock -name clk -period $clk_period [get_ports clk]

set_input_delay 4.0 -clock clk \
    [get_ports {instr_rdata[*] data_rdata[*]}]
set_input_delay 0.0 -clock clk [get_ports rst]
set_output_delay 4.0 -clock clk \
    [get_ports {instr_addr[*] data_read data_write data_wstrb[*] data_addr[*] data_wdata[*]
                trap_valid trap_cause[*] trap_pc[*]}]

# Reset is asynchronous. External memories are assumed combinational for this
# single-cycle educational core. Integration must replace these constraints
# with SoC-level timing.
set_false_path -from [get_ports rst]
