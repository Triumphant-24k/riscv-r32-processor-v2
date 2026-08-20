`timescale 1ns/1ps
module core_tb;
    reg clk, rst;
    wire [31:0] instr_addr, data_addr, data_wdata;
    reg [31:0] instr_rdata;
    reg [31:0] data_rdata;
    wire data_read, data_write;
    wire [3:0] data_wstrb;
    wire trap_valid;
    wire [3:0] trap_cause;
    wire [31:0] trap_pc;
    reg [31:0] imem [0:255];
    reg [7:0] dmem [0:1023];
    integer i, index, checks;
    integer auipc_pc, jal_link, jalr_link, jalr_target;

    cpu_core dut(
        .clk(clk), .rst(rst), .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .data_read(data_read), .data_write(data_write), .data_wstrb(data_wstrb),
        .data_addr(data_addr), .data_wdata(data_wdata), .data_rdata(data_rdata),
        .trap_valid(trap_valid), .trap_cause(trap_cause), .trap_pc(trap_pc)
    );

    always #5 clk = ~clk;
    always @(*) begin
        instr_rdata = imem[instr_addr[9:2]];
        data_rdata = {dmem[{data_addr[9:2],2'b00}+3], dmem[{data_addr[9:2],2'b00}+2],
                      dmem[{data_addr[9:2],2'b00}+1], dmem[{data_addr[9:2],2'b00}]};
    end
    always @(posedge clk) if (data_write) begin
        if (data_wstrb[0]) dmem[{data_addr[9:2],2'b00}] <= data_wdata[7:0];
        if (data_wstrb[1]) dmem[{data_addr[9:2],2'b00}+1] <= data_wdata[15:8];
        if (data_wstrb[2]) dmem[{data_addr[9:2],2'b00}+2] <= data_wdata[23:16];
        if (data_wstrb[3]) dmem[{data_addr[9:2],2'b00}+3] <= data_wdata[31:24];
    end

    function automatic [31:0] enc_r(input [6:0] f7, input [4:0] rs2, input [4:0] rs1,
        input [2:0] f3, input [4:0] rd, input [6:0] op);
        enc_r = {f7,rs2,rs1,f3,rd,op};
    endfunction
    function automatic [31:0] enc_i(input integer imm, input [4:0] rs1, input [2:0] f3,
        input [4:0] rd, input [6:0] op);
        enc_i = {imm[11:0],rs1,f3,rd,op};
    endfunction
    function automatic [31:0] enc_s(input integer imm, input [4:0] rs2, input [4:0] rs1,
        input [2:0] f3);
        enc_s = {imm[11:5],rs2,rs1,f3,imm[4:0],7'b0100011};
    endfunction
    function automatic [31:0] enc_b(input integer imm, input [4:0] rs2, input [4:0] rs1,
        input [2:0] f3);
        enc_b = {imm[12],imm[10:5],rs2,rs1,f3,imm[4:1],imm[11],7'b1100011};
    endfunction
    function automatic [31:0] enc_u(input [19:0] imm, input [4:0] rd, input [6:0] op);
        enc_u = {imm,rd,op};
    endfunction
    function automatic [31:0] enc_j(input integer imm, input [4:0] rd);
        enc_j = {imm[20],imm[10:1],imm[11],imm[19:12],rd,7'b1101111};
    endfunction
    task emit(input [31:0] value); begin imem[index]=value; index=index+1; end endtask
    task clear_memories; begin
        for(i=0;i<256;i=i+1) imem[i]=32'h00000013;
        for(i=0;i<1024;i=i+1) dmem[i]=8'd0;
        index=0;
    end endtask
    task pulse_reset; begin rst=1; @(negedge clk); rst=0; end endtask
    task run_until_trap(input integer max_cycles); integer cycle; begin
        cycle=0;
        while(!trap_valid && cycle<max_cycles) begin @(posedge clk); #1; cycle=cycle+1; end
        if(!trap_valid) $fatal(1,"timeout after %0d cycles at PC %08x",max_cycles,instr_addr);
    end endtask
    task expect_reg(input integer number,input [31:0] expected,input [255:0] name); begin
        checks=checks+1;
        if(dut.register_file_i.registers[number]!==expected)
            $fatal(1,"%0s x%0d got %08x expected %08x",name,number,dut.register_file_i.registers[number],expected);
    end endtask
    task expect_trap(input [3:0] expected,input [255:0] name); begin
        checks=checks+1; if(trap_cause!==expected) $fatal(1,"%0s cause %0d expected %0d",name,trap_cause,expected);
    end endtask

    always @(posedge clk) if(!rst) begin
        if(dut.register_file_i.registers[0] !== 32'd0) $fatal(1,"x0 changed");
        if(!trap_valid && instr_addr[1:0] !== 2'b00) $fatal(1,"unaligned normal PC");
        if(data_read && data_write) $fatal(1,"data read and write asserted together");
        if((data_write && data_wstrb==0) || (!data_write && data_wstrb!=0)) $fatal(1,"write strobe/control mismatch");
    end

    initial begin
        clk=0; rst=1; checks=0; clear_memories();

        // Reset during execution clears all architectural state and restarts at PC zero.
        emit(enc_i(5,0,3'b000,1,7'b0010011));
        @(negedge clk); rst=0; @(posedge clk); #1; expect_reg(1,5,"pre-reset ADDI");
        rst=1; #1; expect_reg(1,0,"reset during execution");
        if(instr_addr!==0) $fatal(1,"reset did not restore PC");

        clear_memories();
        emit(enc_i(-1,0,3'b000,1,7'b0010011));       // ADDI
        emit(enc_i(1,0,3'b000,2,7'b0010011));
        emit(enc_r(0,2,1,3'b000,3,7'b0110011));     // ADD
        emit(enc_r(7'b0100000,1,2,3'b000,3,7'b0110011)); // SUB
        emit(enc_r(0,2,2,3'b001,4,7'b0110011));     // SLL
        emit(enc_r(0,2,1,3'b010,5,7'b0110011));     // SLT
        emit(enc_r(0,2,1,3'b011,6,7'b0110011));     // SLTU
        emit(enc_r(0,2,1,3'b100,7,7'b0110011));     // XOR
        emit(enc_r(0,2,1,3'b101,8,7'b0110011));     // SRL
        emit(enc_r(7'b0100000,2,1,3'b101,9,7'b0110011)); // SRA
        emit(enc_r(0,2,1,3'b110,10,7'b0110011));    // OR
        emit(enc_r(0,2,1,3'b111,11,7'b0110011));    // AND
        emit(enc_i(31,2,3'b001,12,7'b0010011));     // SLLI
        emit(enc_i(0,1,3'b010,13,7'b0010011));      // SLTI
        emit(enc_i(1,1,3'b011,14,7'b0010011));      // SLTIU
        emit(enc_i(15,1,3'b100,15,7'b0010011));     // XORI
        emit(enc_i(85,0,3'b110,16,7'b0010011));     // ORI
        emit(enc_i(85,1,3'b111,17,7'b0010011));     // ANDI
        emit(enc_i(31,12,3'b101,18,7'b0010011));    // SRLI
        emit(enc_i(12'h41f,12,3'b101,19,7'b0010011));// SRAI
        emit(enc_i(128,0,3'b000,20,7'b0010011));
        emit(enc_u(20'ha1b2c,21,7'b0110111));        // LUI
        emit(enc_i(12'h3d4,21,3'b000,21,7'b0010011));
        emit(enc_s(0,21,20,3'b010));                 // SW
        emit(enc_i(0,20,3'b000,22,7'b0000011));     // LB
        emit(enc_i(0,20,3'b100,23,7'b0000011));     // LBU
        emit(enc_i(3,20,3'b000,24,7'b0000011));     // LB offset 3
        emit(enc_i(3,20,3'b100,25,7'b0000011));     // LBU offset 3
        emit(enc_i(0,20,3'b001,26,7'b0000011));     // LH
        emit(enc_i(2,20,3'b101,27,7'b0000011));     // LHU
        emit(enc_i(0,20,3'b010,28,7'b0000011));     // LW
        emit(enc_s(1,2,20,3'b000));                 // SB all offsets covered by loads/stores
        emit(enc_s(2,16,20,3'b001));                // SH upper lane
        emit(enc_i(0,20,3'b010,29,7'b0000011));
        emit(enc_i(0,0,3'b000,1,7'b0010011));
        emit(enc_b(8,0,1,3'b000));                  // BEQ taken, forward
        emit(enc_i(99,0,3'b000,3,7'b0010011));
        emit(enc_i(1,0,3'b000,3,7'b0010011));
        emit(enc_b(8,2,1,3'b001));                  // BNE taken
        emit(enc_i(99,0,3'b000,4,7'b0010011));
        emit(enc_i(2,0,3'b000,4,7'b0010011));
        emit(enc_i(-1,0,3'b000,1,7'b0010011));
        emit(enc_b(8,2,1,3'b100));                  // BLT taken signed
        emit(enc_i(99,0,3'b000,5,7'b0010011));
        emit(enc_i(3,0,3'b000,5,7'b0010011));
        emit(enc_b(8,1,2,3'b101));                  // BGE taken signed
        emit(enc_i(99,0,3'b000,6,7'b0010011));
        emit(enc_i(4,0,3'b000,6,7'b0010011));
        emit(enc_b(8,1,2,3'b110));                  // BLTU taken unsigned
        emit(enc_i(99,0,3'b000,7,7'b0010011));
        emit(enc_i(5,0,3'b000,7,7'b0010011));
        emit(enc_b(8,2,1,3'b111));                  // BGEU taken unsigned
        emit(enc_i(99,0,3'b000,8,7'b0010011));
        emit(enc_i(6,0,3'b000,8,7'b0010011));
        emit(enc_b(8,2,1,3'b000));                  // BEQ not taken
        emit(enc_i(7,0,3'b000,9,7'b0010011));
        emit(enc_i(2,0,3'b000,1,7'b0010011));
        emit(enc_i(-1,1,3'b000,1,7'b0010011));
        emit(enc_b(-4,0,1,3'b001));                 // backward BNE taken then not taken
        auipc_pc=index*4; emit(enc_u(20'h12345,10,7'b0010111)); // AUIPC
        jal_link=(index+1)*4; emit(enc_j(8,11));     // JAL
        emit(enc_i(99,0,3'b000,12,7'b0010011));
        emit(enc_i(8,0,3'b000,12,7'b0010011));
        jalr_target=(index+3)*4;
        emit(enc_i(jalr_target+1,0,3'b000,30,7'b0010011));
        jalr_link=(index+1)*4; emit(enc_i(0,30,3'b000,31,7'b1100111)); // JALR clears bit 0
        emit(enc_i(99,0,3'b000,13,7'b0010011));
        emit(enc_i(9,0,3'b000,13,7'b0010011));
        emit(32'h0000000f);                          // FENCE
        emit(enc_i(123,0,3'b000,0,7'b0010011));     // x0 write attempt
        emit(32'h00000073);                          // ECALL
        pulse_reset(); run_until_trap(150); expect_trap(11,"ECALL");
        i=instr_addr; repeat(2) @(posedge clk); #1;
        if(instr_addr!==i) $fatal(1,"trap did not halt PC");

        expect_reg(0,0,"x0 invariant"); expect_reg(3,1,"BEQ"); expect_reg(4,2,"BNE");
        expect_reg(5,3,"BLT"); expect_reg(6,4,"BGE"); expect_reg(7,5,"BLTU");
        expect_reg(8,6,"BGEU"); expect_reg(9,7,"branch not taken");
        expect_reg(10,32'h12345000+auipc_pc,"AUIPC"); expect_reg(11,jal_link,"JAL link");
        expect_reg(12,8,"JAL target"); expect_reg(13,9,"JALR target"); expect_reg(31,jalr_link,"JALR link");
        expect_reg(14,0,"SLTIU"); expect_reg(15,32'hfffffff0,"XORI");
        expect_reg(16,85,"ORI"); expect_reg(17,85,"ANDI"); expect_reg(18,1,"SRLI");
        expect_reg(19,32'hffffffff,"SRAI"); expect_reg(21,32'ha1b2c3d4,"LUI/addi");
        expect_reg(22,32'hffffffd4,"LB"); expect_reg(23,32'hd4,"LBU");
        expect_reg(24,32'hffffffa1,"LB offset 3"); expect_reg(25,32'ha1,"LBU offset 3");
        expect_reg(26,32'hffffc3d4,"LH"); expect_reg(27,32'ha1b2,"LHU");
        expect_reg(28,32'ha1b2c3d4,"LW"); expect_reg(29,32'h005501d4,"SB/SH strobes");

        // Illegal instruction and all required synchronous exception classes.
        clear_memories(); emit(32'hffffffff); pulse_reset(); run_until_trap(3); expect_trap(2,"illegal instruction");
        clear_memories(); emit(32'h00100073); pulse_reset(); run_until_trap(3); expect_trap(3,"EBREAK");
        clear_memories(); emit(enc_i(1,0,3'b010,1,7'b0000011)); pulse_reset(); run_until_trap(3); expect_trap(4,"misaligned LW"); expect_reg(1,0,"faulting load no writeback");
        clear_memories(); emit(enc_i(1,0,3'b001,1,7'b0000011)); pulse_reset(); run_until_trap(3); expect_trap(4,"misaligned LH");
        clear_memories(); emit(enc_i(7,0,3'b000,1,7'b0010011)); emit(enc_s(2,1,0,3'b010)); pulse_reset(); run_until_trap(5); expect_trap(6,"misaligned SW");
        clear_memories(); emit(enc_i(7,0,3'b000,1,7'b0010011)); emit(enc_s(1,1,0,3'b001)); pulse_reset(); run_until_trap(5); expect_trap(6,"misaligned SH");
        clear_memories(); emit(enc_i(2,0,3'b000,1,7'b0010011)); emit(enc_i(0,1,3'b000,2,7'b1100111)); pulse_reset(); run_until_trap(5); expect_trap(0,"misaligned JALR"); expect_reg(2,0,"faulting JALR no link");

        $display("PASS: complete directed core regression (%0d checks)",checks);
        $finish;
    end
endmodule
