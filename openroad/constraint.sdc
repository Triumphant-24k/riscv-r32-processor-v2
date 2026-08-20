# Conservative 50 MHz starting constraint.
set clk_period 20.0
create_clock -name clk -period $clk_period [get_ports clk]

set_input_delay 4.0 -clock clk \
    [get_ports {instr_req_ready instr_rsp_valid instr_rsp_data[*]
                data_req_ready data_rsp_valid data_rsp_rdata[*]}]
set_input_delay 0.0 -clock clk [get_ports rst]
set_output_delay 4.0 -clock clk \
    [get_ports {instr_req_valid instr_req_addr[*]
                data_req_valid data_req_write data_req_wstrb[*]
                data_req_addr[*] data_req_wdata[*]
                trap_valid trap_cause[*] trap_pc[*]}]

# Reset is asynchronous. The request/response ports are constrained as a
# conservative single-clock interface. Integration must replace these starter
# delays with the actual interconnect and memory timing, and must ensure reset
# deassertion satisfies recovery/removal requirements.
set_false_path -from [get_ports rst]
