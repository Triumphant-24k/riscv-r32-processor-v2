module cpu_core (
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] instr_addr,
    input  wire [31:0] instr_rdata,
    output wire        data_read,
    output wire        data_write,
    output wire [3:0]  data_wstrb,
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input  wire [31:0] data_rdata,
    output reg         trap_valid,
    output reg  [3:0]  trap_cause,
    output reg  [31:0] trap_pc
);
    localparam WB_ALU = 2'd0;
    localparam WB_LOAD = 2'd1;
    localparam WB_PC4 = 2'd2;
    localparam CAUSE_INSTR_MISALIGNED = 4'd0;
    localparam CAUSE_ILLEGAL = 4'd2;
    localparam CAUSE_BREAKPOINT = 4'd3;
    localparam CAUSE_LOAD_MISALIGNED = 4'd4;
    localparam CAUSE_STORE_MISALIGNED = 4'd6;
    localparam CAUSE_ECALL_M = 4'd11;

    reg [31:0] pc;
    wire [4:0] rd = instr_rdata[11:7];
    wire [4:0] rs1 = instr_rdata[19:15];
    wire [4:0] rs2 = instr_rdata[24:20];
    wire [2:0] funct3 = instr_rdata[14:12];
    wire [31:0] rs1_value;
    wire [31:0] rs2_value;
    wire [31:0] immediate;
    wire [3:0] alu_operation;
    wire [2:0] immediate_select;
    wire [1:0] writeback_select;
    wire alu_source_immediate;
    wire alu_source_pc;
    wire decoded_register_write;
    wire decoded_memory_read;
    wire decoded_memory_write;
    wire decoded_branch;
    wire decoded_jump;
    wire decoded_jump_register;
    wire decoded_upper_immediate;
    wire decoded_fence;
    wire decoded_ecall;
    wire decoded_ebreak;
    wire illegal_instruction;
    wire [31:0] alu_a = alu_source_pc ? pc : rs1_value;
    wire [31:0] alu_b = alu_source_immediate ? immediate : rs2_value;
    wire [31:0] alu_result_raw;
    wire [31:0] alu_result = decoded_upper_immediate ? immediate : alu_result_raw;
    wire branch_taken;
    wire [31:0] pc_plus_4 = pc + 32'd4;
    wire [31:0] branch_target = pc + immediate;
    wire [31:0] jal_target = pc + immediate;
    wire [31:0] jalr_target = (rs1_value + immediate) & 32'hfffffffe;
    wire [31:0] control_target = decoded_jump_register ? jalr_target :
                                 decoded_jump ? jal_target : branch_target;
    wire control_transfer = decoded_jump || decoded_jump_register || (decoded_branch && branch_taken);
    wire instruction_misaligned = control_transfer && (control_target[1:0] != 2'b00);
    wire [31:0] load_value;
    wire [31:0] store_data;
    wire [3:0] store_strobe;
    wire data_misaligned;
    wire synchronous_trap = illegal_instruction || decoded_ecall || decoded_ebreak ||
                            instruction_misaligned || data_misaligned;
    wire architectural_write_enable = decoded_register_write && !synchronous_trap && !trap_valid;
    wire [31:0] writeback_data = (writeback_select == WB_LOAD) ? load_value :
                                 (writeback_select == WB_PC4) ? pc_plus_4 : alu_result;

    assign instr_addr = pc;
    assign data_addr = alu_result_raw;
    assign data_wdata = store_data;
    assign data_wstrb = (decoded_memory_write && !data_misaligned && !illegal_instruction && !trap_valid) ? store_strobe : 4'b0000;
    assign data_read = decoded_memory_read && !data_misaligned && !illegal_instruction && !trap_valid;
    assign data_write = decoded_memory_write && !data_misaligned && !illegal_instruction && !trap_valid;

    control_unit control (
        .instruction(instr_rdata), .alu_operation(alu_operation),
        .immediate_select(immediate_select), .writeback_select(writeback_select),
        .alu_source_immediate(alu_source_immediate), .alu_source_pc(alu_source_pc),
        .register_write(decoded_register_write), .memory_read(decoded_memory_read),
        .memory_write(decoded_memory_write), .branch(decoded_branch), .jump(decoded_jump),
        .jump_register(decoded_jump_register), .upper_immediate(decoded_upper_immediate),
        .fence(decoded_fence), .ecall(decoded_ecall), .ebreak(decoded_ebreak),
        .illegal_instruction(illegal_instruction)
    );

    immediate_generator immediate_generator_i (
        .instruction(instr_rdata), .immediate_select(immediate_select), .immediate(immediate)
    );

    register_file register_file_i (
        .clk(clk), .rst(rst), .write_enable(architectural_write_enable),
        .read_address_1(rs1), .read_address_2(rs2), .write_address(rd),
        .write_data(writeback_data), .read_data_1(rs1_value), .read_data_2(rs2_value)
    );

    alu alu_i (.a(alu_a), .b(alu_b), .operation(alu_operation), .result(alu_result_raw));
    branch_unit branch_unit_i (.operand_a(rs1_value), .operand_b(rs2_value), .funct3(funct3), .taken(branch_taken));
    load_store_unit load_store_unit_i (
        .funct3(funct3), .address_offset(alu_result_raw[1:0]), .store_value(rs2_value),
        .memory_read_data(data_rdata), .is_load(decoded_memory_read),
        .is_store(decoded_memory_write), .load_value(load_value),
        .memory_write_data(store_data), .memory_write_strobe(store_strobe),
        .misaligned(data_misaligned)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'd0;
            trap_valid <= 1'b0;
            trap_cause <= 4'd0;
            trap_pc <= 32'd0;
        end else if (!trap_valid) begin
            if (synchronous_trap) begin
                trap_valid <= 1'b1;
                trap_pc <= pc;
                if (instruction_misaligned) trap_cause <= CAUSE_INSTR_MISALIGNED;
                else if (illegal_instruction) trap_cause <= CAUSE_ILLEGAL;
                else if (decoded_ebreak) trap_cause <= CAUSE_BREAKPOINT;
                else if (data_misaligned && decoded_memory_read) trap_cause <= CAUSE_LOAD_MISALIGNED;
                else if (data_misaligned && decoded_memory_write) trap_cause <= CAUSE_STORE_MISALIGNED;
                else trap_cause <= CAUSE_ECALL_M;
            end else if (control_transfer) begin
                pc <= control_target;
            end else begin
                pc <= pc_plus_4;
            end
        end
    end
endmodule
