module cpu_sim_top #(
    parameter PROGRAM_HEX = ""
) (
    input wire clk,
    input wire rst,
    output wire trap_valid,
    output wire [3:0] trap_cause,
    output wire [31:0] trap_pc
);
    wire [31:0] instr_addr;
    wire [31:0] instr_rdata;
    wire data_read;
    wire data_write;
    wire [3:0] data_wstrb;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;

    cpu_core core (
        .clk(clk), .rst(rst), .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .data_read(data_read), .data_write(data_write), .data_wstrb(data_wstrb),
        .data_addr(data_addr), .data_wdata(data_wdata), .data_rdata(data_rdata),
        .trap_valid(trap_valid), .trap_cause(trap_cause), .trap_pc(trap_pc)
    );
    simulation_memory #(.PROGRAM_HEX(PROGRAM_HEX)) memory (
        .clk(clk), .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .data_read(data_read), .data_write(data_write), .data_wstrb(data_wstrb),
        .data_addr(data_addr), .data_wdata(data_wdata), .data_rdata(data_rdata)
    );
endmodule
