`timescale 1ns / 1ps

module decoder_pricol(
    input logic [31:0] fetched_instr_i,
        
    output logic [1:0] a_sel_o,         //
    output logic [2:0] b_sel_o,
    output logic [4:0] alu_op_o,
    output logic [2:0] csr_op_o,
    output logic       csr_we_o,
    output logic       mem_req_o,
    output logic       mem_we_o,
    output logic [2:0] mem_size_o,
    output logic       gpr_we_o,        //
    output logic [1:0] wb_sel_o,
    output logic       illegal_instr_o,
    output logic       branch_o,
    output logic       jal_o,
    output logic       jalr_o,
    output logic       mret_o           //
    );
    
    import riscv_pkg::*;
    
    logic  [6:0] opcode;
    logic  [2:0] funct3;
    logic  [6:0] funct7;
    
    assign opcode = fetched_instr_i[ 6: 0];
    assign funct3 = fetched_instr_i[14:12];
    assign funct7 = fetched_instr_i[31:25];
    
//    assign a_sel_o = (
//        opcode == 7'b1101111 | 
//        opcode == 7'b1100111 & ( 
//            funct3 == 3'b000 
//            ) |
//        opcode == 7'b0010111 
//    ) ? 'b01 : ((
//        opcode == 7'b0110111
//    ) ? 'b10: 'b00 );
    
//    assign b_sel_o = (
//        opcode == 7'b0010011 |
//        opcode == 7'b0000011 
//    ) ? 'b01 : ((
//        opcode == 7'b0100011
//    ) ? 'b011 : 'b0);
    
    assign gpr_we_o = (
        opcode == 'b0110011 & (
            funct3 == 'b000 & (funct7 == 'b0000000  | funct7 == 'b0100000) |
            funct3 == 'b001 & (funct7 == 'b0000000) |
            funct3 == 'b010 & (funct7 == 'b0000000) | 
            funct3 == 'b011 & (funct7 == 'b0000000) |
            funct3 == 'b100 & (funct7 == 'b0000000) |
            funct3 == 'b101 & (funct7 == 'b0000000  | funct7 == 'b0100000) |
            funct3 == 'b110 & (funct7 == 'b0000000  | funct7 == 'b0100000) |
            funct3 == 'b111 & (funct7 == 'b0000000)
        ) |
        opcode == 'b0010011 & (
            funct3 == 'b000 |
            funct3 == 'b001 & (funct7 == 'b0000000) |
            funct3 == 'b010 |
            funct3 == 'b011 |
            funct3 == 'b100 |
            funct3 == 'b101 & (funct7 == 'b0000000 | funct7 == 'b0100000) |
            funct3 == 'b110 |
            funct3 == 'b111
        ) |
        opcode == 'b0000011 & (
            funct3 == 'b000 |
            funct3 == 'b001 |
            funct3 == 'b010 |
            funct3 == 'b100 |
            funct3 == 'b101
        ) |
        opcode == 'b1101111 | 
        opcode == 'b1100111 & funct3 == 'b000 |
        opcode == 'b0110111 |
        opcode == 'b0010111 |
        opcode == 'b1110011 & (
            funct3 == 'b001 |
            funct3 == 'b010 |
            funct3 == 'b011 |
            funct3 == 'b101 |
            funct3 == 'b110 |
            funct3 == 'b111
        )
    ) ? 'b1 : 'b0;
    
    assign mem_req_o = (
        opcode == 'b0000011 & (
            funct3 == 'b000 |
            funct3 == 'b001 |
            funct3 == 'b010 |
            funct3 == 'b100 |
            funct3 == 'b101 
        ) |
        opcode == 'b0100011 & (
            funct3 == 'b000 |
            funct3 == 'b001 |
            funct3 == 'b010
        )
    ) ? 'b1 : 'b0;
    
    assign mem_we_o = (
        opcode == 'b0100011 & (
            funct3 == 'b000 |
            funct3 == 'b001 |
            funct3 == 'b010
        )
    ) ? 'b1 : 'b0;
    
    assign mem_size_o = (
        opcode == 7'b0000011 & funct3 == 'b001 |
        opcode == 7'b0100011 & funct3 == 'b001
    ) ? 'b001 : ((
        opcode == 7'b0000011 & funct3 == 'b010 |
        opcode == 7'b0100011 & funct3 == 'b010
    ) ? 'b010 : ((
        opcode == 7'b0000011 & funct3 == 'b100 
    ) ? 'b100 : ((
        opcode == 7'b0000011 & funct3 == 'b101 
    ) ? 'b101 : 'b000)));    
    assign jal_o = (
        opcode == 'b1101111
    ) ? 'b1 : 'b0;
    assign jalr_o = (
        opcode == 'b1100111 & funct3 == 'b000 
    ) ? 'b1 : 'b0;    
    assign branch_o = (
        opcode == 'b1100011 & (
            funct3 == 'b000 |
            funct3 == 'b001 | 
            funct3 == 'b100 | 
            funct3 == 'b101 | 
            funct3 == 'b110 | 
            funct3 == 'b111 
        )
    ) ? 'b1 : 'b0;    
    assign mret_o = (fetched_instr_i == 'b00110000001000000000000001110011) ? 'b1 : 'b0;
    
endmodule
