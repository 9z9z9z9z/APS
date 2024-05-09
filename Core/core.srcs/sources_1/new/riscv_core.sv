`timescale 1ns / 1ps
module riscv_core(
        input logic         clk_i,
        input logic         rst_i,
        input logic         stall_i,
        input logic         irq_req_i,
        
        input logic  [31:0] instr_i,
        input logic  [31:0] mem_rd_i,
        
        output logic [31:0] instr_addr_o,
        output logic [31:0] mem_addr_o,
        output logic [3:0]  mem_size_o,
        output logic        mem_req_o,
        output logic        mem_we_o,
        output logic [31:0] mem_wd_o,
        output logic        irq_ret_o 
    );

    logic           gpr_we;
    logic [1 :0]    wb_sel;
    logic [31:0]    wb_data;
    logic [31:0]    RD1;
    logic [31:0]    RD2;
    logic [31:0]    PC;
    logic [31:0]    imm_I;
    logic [31:0]    imm_U;
    logic [31:0]    imm_S;
    logic [31:0]    imm_B;
    logic [31:0]    imm_J;
    logic [31:0]    imm_Z;
    logic           flag;
    logic [1 :0]    a_sel;
    logic [2 :0]    b_sel;
    logic           branch;
    logic           ill_instr;
    logic           irq;
    logic [31:0]    irq_cause;
    logic [31:0]    mcause;
    logic [31:0]    csr_wd;
    logic [31:0]    mie;
    logic           mret;
    logic           trap;
    logic           jal;
    logic           jalr;
    logic           mem_we;
    logic           mem_req;
    logic [31:0]    mepc;
    logic [31:0]    mtvec;
    logic           csr_we;
    logic [2 :0]    csr_op;
    logic [4 :0]    alu_op;
    logic [31:0]    alu_a_i;
    logic [31:0]    alu_b_i;
    logic [31:0]    alu_result;
    logic [31:0]    new_PC_RD1;
    logic [31:0]    PC_Loop_b_i;
    logic [31:0]    new_PC_Loop;
    logic [31:0]    PC_RD1_adder_result;
    logic [31:0]    PC_Jalr_mult;
    logic [31:0]    PC_Trap_mult;
    logic [31:0]    new_PC;
    
    
    
    assign imm_I        = $signed(instr_i[31:20]);
    assign imm_U        = {instr_i[31:12], 12'b0};
    assign imm_S        = $signed({instr_i[31:25], instr_i[11:7]});
    assign imm_B        = $signed({instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0});
    assign imm_J        = $signed({instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0});
    assign imm_Z        = $signed(instr_i[19:15]);
    
    assign alu_a_i      = (a_sel  == 'b00 ) ? RD1 : ((a_sel == 'b01) ? PC : 'b0);
    assign alu_b_i      = (b_sel  == 'b000) ? RD2 : ((b_sel == 'b001) ? imm_I : (
                          (b_sel  == 'b010) ? imm_U : ((b_sel == 'b011) ? imm_S : 'b100)));
    assign wb_data      = (wb_sel == 'b00 ) ? alu_result : ((wb_sel == 'b01) ? mem_rd_i : csr_wd);
    
    assign PC_Loop_b_i = (jal | (flag & branch)) ?  (
        (branch) ? imm_B : imm_J
    ) : 'b100;
    
    assign new_PC_RD1   = {PC_RD1_adder_result[31:1], 1'b0};
    assign PC_Jalr_mult = (jalr == 'b1) ? new_PC_RD1 : new_PC_Loop;
    assign PC_Trap_mult = (trap == 'b1) ? mtvec : PC_Jalr_mult;
    assign new_PC       = (mret == 'b1) ? mepc : PC_Trap_mult;
    
    assign trap         = irq | ill_instr;
    assign mcause       = (ill_instr) ? 32'h0000_0002 : irq_cause;
    
    assign mem_wd_o     = RD2;
    assign mem_addr_o   = alu_result; 
    assign mem_we_o     = mem_we & ~trap;
    assign mem_req_o    = mem_req & ~trap;
    assign instr_addr_o = PC;
          
    interrupt_controller IRQ_Controller(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .exception_i(ill_instr),
        .irq_req_i(irq_req_i),
        .mie_i(mie[0]),
        .mret_i(mret),
        
        .irq_ret_o(irq_ret_o),
        .irq_o(irq),
        .irq_cause_o(irq_cause)
    );
          
    csr_controller CSR_Controller (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .trap_i(trap),
        .opcode_i(csr_op),
        .addr_i(instr_i[31:20]),
        .pc_i(PC),
        .mcause_i(mcause),
        .rs1_data_i(RD1),
        .imm_data_i(imm_Z),
        .write_enable_i(csr_we),
        
        .read_data_o(csr_wd),
        .mie_o(mie),
        .mepc_o(mepc),
        .mtvec_o(mtvec)
    );
          
    rf_riscv RgisterFile(
        .clk_i(clk_i),
        
        .write_enable_i(gpr_we & ~(stall_i | trap)),
        .write_addr_i(instr_i[11:7]),
        .write_data_i(wb_data),
        
        .read_addr1_i(instr_i[19:15]),
        .read_addr2_i(instr_i[24:20]),
        
        .read_data1_o(RD1),
        .read_data2_o(RD2)
    );

    decoder_riscv MainDecoder (        
        .fetched_instr_i(instr_i),
        
        .gpr_we_o(gpr_we),
        .a_sel_o(a_sel),
        .b_sel_o(b_sel),
        .alu_op_o(alu_op),
        .wb_sel_o(wb_sel),
        .mem_we_o(mem_we),
        .mem_req_o(mem_req),
        .mem_size_o(mem_soze_o),        
        .branch_o(branch),
        .jal_o(jal),
        .jalr_o(jalr),
        .mret_o(mret),
        .illegal_instr_o(ill_instr),
        .csr_we_o(csr_we),
        .csr_op_o(csr_op)
    );

    
    alu_riscv ALU (
        .a_i(alu_a_i),
        .b_i(alu_b_i),
        .alu_op_i(alu_op),
        
        .flag_o(flag),
        .result_o(alu_result)
    );
    
    fulladder32 PC_RD1_Adder (
        .a_i(RD1),
        .b_i(imm_I),
        .carry_i('b0),
        
        .sum_o(PC_RD1_adder_result)
    );
    
    fulladder32 PC_Loop_Adder (
        .a_i(PC),
        .b_i(PC_Loop_b_i),
        .carry_i('b0),
        
        .sum_o(new_PC_Loop)
    );
    
    // PC
    always_ff @(posedge clk_i) begin
        if (~stall_i | trap) begin 
            if (rst_i) begin 
                PC <= 'b0;
            end
            else PC <= new_PC; 
        end
    end
    
endmodule
