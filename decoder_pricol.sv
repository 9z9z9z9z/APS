`timescale 1ns / 1ps

module decoder_pricol(
    input logic [31:0] fetched_instr_i,
        
    output logic [1:0] a_sel_o,         // done
    output logic [2:0] b_sel_o,         // done
    output logic [4:0] alu_op_o,        // done
    output logic [2:0] csr_op_o,        // done
    output logic       csr_we_o,        // done
    output logic       mem_req_o,       // done
    output logic       mem_we_o,        // done
    output logic [2:0] mem_size_o,      // done
    output logic       gpr_we_o,        // done
    output logic [1:0] wb_sel_o,        // done
    output logic       illegal_instr_o, // wtf
    output logic       branch_o,        // done
    output logic       jal_o,           // done
    output logic       jalr_o,          // done
    output logic       mret_o           // done
    );
    
    import riscv_pkg::*;
    
    logic  [6:0] opcode;
    logic  [2:0] funct3;
    logic  [6:0] funct7;
    
    assign opcode = fetched_instr_i[ 6: 0];
    assign funct3 = fetched_instr_i[14:12];
    assign funct7 = fetched_instr_i[31:25];
    
    assign a_sel_o = (
        opcode == 7'b1101111 |          // jal
        (opcode == 7'b1100111 &         // jalr
            funct3 == 3'b000 
            ) |
        opcode == 7'b0010111            // aluipc
    ) ? 'b01 : ((
        opcode == 7'b0110111            // lui
    ) ? 'b10: 'b0
    );
    
    assign b_sel_o = (
        opcode == 7'b0010011 |          // imm operations
        opcode == 7'b0000011            // loads
    ) ? 'b01 : ((
        opcode == 7'b0100011            // saves
    ) ? 'b011 : 'b0
    );
    
    assign csr_we_o = (
        opcode == 'b1110011 & (         // csr options
            funct3 == 'b001 |
            funct3 == 'b010 |
            funct3 == 'b011 |
            funct3 == 'b101 |
            funct3 == 'b110 |
            funct3 == 'b111
        )
    ) ? 'b1 : 'b0;
    
    assign csr_op_o = (opcode != 1110011) ? 'b0 : (
        (funct3 == 'b001 ? CSR_RW  : (
         funct3 == 'b010 ? CSR_RS  : (
         funct3 == 'b011 ? CSR_RC  : (
         funct3 == 'b101 ? CSR_RWI : (
         funct3 == 'b110 ? CSR_RSI : (
         funct3 == 'b111 ? CSR_RCI : 'b0
         ))))))
    );
    
    assign alu_op_o = (
        opcode == 'b0110011 & funct3 == 'b000 & funct7 == 'b0000000 |
        opcode == 'b0010011 & funct3 == 'b000 |
        opcode == 'b0000011 |
        opcode == 'b0100011 |
        opcode == 'b1101111 |
        opcode == 'b1100111 & funct3 == 'b000 |
        opcode == 'b0110111 |
        opcode == 'b0010111
    ) ? ALU_ADD     : (( // add done
        opcode == 'b0110011 & funct3 == 'b000 & funct7 == 'b0100000
    ) ? ALU_SUB     : (( // sub done
        opcode == 'b0110011 & funct3 == 'b100 & funct7 == 'b0000000 |
        opcode == 'b0010011 & funct3 == 'b100
    ) ? ALU_XOR     : (( // xor done
        opcode == 'b0110011 & funct3 == 'b110 & funct7 == 'b0000000 |
        opcode == 'b0010011 & funct3 == 'b110
    ) ? ALU_OR      : (( // or done
        opcode == 'b0110011 & funct3 == 'b111 & funct7 == 'b0000000 |
        opcode == 'b0010011 & funct3 == 'b111
    ) ? ALU_AND     : (( // and done
       (opcode == 'b0110011 | opcode == 'b0010011)
          & funct3 == 'b101 & funct7 == 'b0100000         
    ) ? ALU_SRA     : (( // sra done
       (opcode == 'b0110011 | opcode == 'b0010011)
          & funct3 == 'b101 & funct7 == 'b0000000 
    ) ? ALU_SRL     : (( // srl done
       (opcode == 'b0110011 | opcode == 'b0010011)
          & funct3 == 'b001 & funct7 == 'b0000000
    ) ? ALU_SLL     : (( // sll done
        opcode == 'b1100011 & funct3 == 'b100
    ) ? ALU_LTS     : (( // lts done
        opcode == 'b1100011 & funct3 == 'b110
    ) ? ALU_LTU     : (( // ltu done
        opcode == 'b1100011 & funct3 == 'b101
    ) ? ALU_GES     : (( // ges done
        opcode == 'b1100011 & funct3 == 'b111
    ) ? ALU_GEU     : (( // geu done
        opcode == 'b1100011 & funct3 == 'b000
    ) ? ALU_EQ      : (( // eq done
        opcode == 'b1100011 & funct3 == 'b001
    ) ? ALU_NE      : (( // ne done
        opcode == 'b0110011 & funct3 == 'b010 & funct7 == 'b0000000 |
        opcode == 'b0010011 & funct3 == 'b010
    ) ? ALU_SLTS    : (( // slts done
        opcode == 'b0110011 & funct3 == 'b011 & funct7 == 'b0000000 |
        opcode == 'b0010011 & funct3 == 'b011
    ) ? ALU_SLTU : 'b0
    )))))))))))))));
    
    assign wb_sel_o = (
        opcode == 'b0000011                 // loads
    ) ? 'b1 : ((
        opcode == 'b1110011 & (         // csr options
            funct3 == 'b001 |
            funct3 == 'b010 |
            funct3 == 'b011 |
            funct3 == 'b101 |
            funct3 == 'b110 |
            funct3 == 'b111
        )
    ) ? 'b10 : 'b0);
    
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
    ) ? 'b101 : 'b0
    )));    
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
    
    assign illegal_instr_i = (
        (opcode == 'b0110011 & (
            funct3 == 'b000 & (funct7 == 'b0000000 | funct7 == 'b0100000) |
            ((funct3 == 'b001 | funct3 == 'b010 | funct3 == 'b011 |
             funct3 == 'b100 | funct3 == 'b110 | funct3 == 'b111 ) & funct7 == 'b0000000) |
             funct3 == 'b101 & (funct7 == 'b0000000 | funct7 == 'b0100000) 
         ) |
         (opcode == 'b0010011 & (
            (funct3 == 'b000 | funct3 == 'b100 | funct3 == 'b110 | funct3 == 'b111) |
             funct3 == 'b001 & (funct7 == 'b0000000) |
             funct3 == 'b101 & (funct7 == 'b0000000  | funct7 == 'b0100000))
         ) // TODO
         
        )
    ) ? 'b0 : 'b1;
endmodule
