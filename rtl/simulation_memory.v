module simulation_memory #(
    parameter IMEM_WORDS = 1024,
    parameter DMEM_BYTES = 4096,
    parameter PROGRAM_HEX = ""
) (
    input  wire        clk,
    input  wire [31:0] instr_addr,
    output wire [31:0] instr_rdata,
    input  wire        data_read,
    input  wire        data_write,
    input  wire [3:0]  data_wstrb,
    input  wire [31:0] data_addr,
    input  wire [31:0] data_wdata,
    output wire [31:0] data_rdata
);
    reg [31:0] instruction_memory [0:IMEM_WORDS-1];
    reg [7:0] data_memory [0:DMEM_BYTES-1];
    integer index;

    initial begin
        for (index = 0; index < IMEM_WORDS; index = index + 1)
            instruction_memory[index] = 32'h00000013;
        for (index = 0; index < DMEM_BYTES; index = index + 1)
            data_memory[index] = 8'd0;
        if (PROGRAM_HEX != "")
            $readmemh(PROGRAM_HEX, instruction_memory);
    end

    assign instr_rdata = instruction_memory[instr_addr[31:2]];
    assign data_rdata = data_read ? {
        data_memory[{data_addr[31:2], 2'b00} + 32'd3],
        data_memory[{data_addr[31:2], 2'b00} + 32'd2],
        data_memory[{data_addr[31:2], 2'b00} + 32'd1],
        data_memory[{data_addr[31:2], 2'b00}]
    } : 32'd0;

    always @(posedge clk) begin
        if (data_write) begin
            if (data_wstrb[0]) data_memory[{data_addr[31:2], 2'b00}] <= data_wdata[7:0];
            if (data_wstrb[1]) data_memory[{data_addr[31:2], 2'b00} + 32'd1] <= data_wdata[15:8];
            if (data_wstrb[2]) data_memory[{data_addr[31:2], 2'b00} + 32'd2] <= data_wdata[23:16];
            if (data_wstrb[3]) data_memory[{data_addr[31:2], 2'b00} + 32'd3] <= data_wdata[31:24];
        end
    end
endmodule
