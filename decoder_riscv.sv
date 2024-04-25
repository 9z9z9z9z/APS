`timescale 1ns / 1ps

module decoder_riscv(
        input logic [31:0] fetched_instr_i,
        
        output logic [1:0] a_sel_o,
        output logic [2:0] b_sel_o,
        output logic [4:0] alu_op_o,
        output logic [2:0] csr_op_o,
        output logic       csr_we_o,
        output logic       mem_req_o, // Ability to contact with data
        output logic       mem_we_o, // Ability to write data
        output logic [2:0] mem_size_o, // Size of nesessary memory
        output logic       gpr_we_o, 
        output logic [1:0] wb_sel_o,
        output logic       illegal_instr_o,
        output logic       branch_o,
        output logic       jal_o,
        output logic       jalr_o,
        output logic       mret_o        
    );    
    
    import riscv_pkg::*;    
    
    logic  [6:0] opcode;
    logic  [2:0] funct3;
    logic  [6:0] funct7;
    
    assign opcode = fetched_instr_i[ 6: 0];
    assign funct3 = fetched_instr_i[14:12];
    assign funct7 = fetched_instr_i[31:25];    
    always_comb begin
        a_sel_o         = 'b0;
        b_sel_o         = 'b0;
        alu_op_o        = 'b0;
        csr_op_o        = 'b0;
        csr_we_o        = 'b0;
        mem_req_o       = 'b0;
        mem_we_o        = 'b0;
        mem_size_o      = 'b0;                                
        gpr_we_o        = 'b0;
        wb_sel_o        = 'b0;
        illegal_instr_o = 'b0;
        branch_o        = 'b0;
        jal_o           = 'b0;
        jalr_o          = 'b0;
        mret_o          = 'b0; 
                 
        case(opcode)            
            7'b0110011: begin
                gpr_we_o = 'b1;
                case (funct3)
                    3'b000: 
                        case(funct7)
                            7'b0000000: //ADD
                                alu_op_o = ALU_ADD;                               
                            7'b0100000: // SUB
                                alu_op_o = ALU_SUB;
                            default: begin
                                gpr_we_o = 'b0;
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b001:
                        case(funct7)
                            7'b0000000: //SLL
                                alu_op_o = ALU_SLL;
                            default: begin
                                gpr_we_o = 'b0;
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b010:
                        case(funct7)
                            7'b0000000: //SLT
                                alu_op_o = ALU_SLTS;
                            default: begin
                                gpr_we_o = 'b0;
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b011:
                        case(funct7)
                            7'b0000000: // SLTU
                                alu_op_o = ALU_SLTU;
                            default: begin
                                gpr_we_o = 'b0;                            
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b100:
                        case(funct7)
                            7'b0000000: // XOR
                                alu_op_o = ALU_XOR;
                            default: begin
                                gpr_we_o = 'b0;                            
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b101:
                        case(funct7)
                            7'b0000000: // SRL
                                alu_op_o = ALU_SRL;
                            7'b0100000: // SRA
                                alu_op_o = ALU_SRA;
                            default: begin
                                gpr_we_o = 'b0;                            
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b110: // OR
                        case(funct7)
                            7'b0000000: // OR
                                alu_op_o = ALU_OR;
                            default: begin
                                gpr_we_o = 'b0;                                
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b111:
                        case(funct7)
                            7'b0000000: // AND
                                alu_op_o = ALU_AND;
                            default: begin
                                gpr_we_o = 'b0;                            
                                illegal_instr_o = 1;
                            end
                        endcase
                endcase            
            end            
            7'b0010011: begin 
                gpr_we_o = 'b1;       
                b_sel_o  = 'b1;                      
                case (funct3)
                    3'b000: 
                        alu_op_o = ALU_ADD;
                    3'b001: 
                        case(funct7)
                            7'b0000000: 
                                alu_op_o = ALU_SLL;
                            default: begin
                                gpr_we_o = 'b0;       
                                b_sel_o  = 'b0;
                                illegal_instr_o = 1;
                            end
                        endcase
                    3'b010: 
                        alu_op_o = ALU_SLTS;
                    3'b011: 
                        alu_op_o = ALU_SLTU;
                    3'b100: 
                        alu_op_o = ALU_XOR;
                    3'b101: begin
                        case(funct7)
                            7'b0000000: 
                                alu_op_o = ALU_SRL;
                            7'b0100000: 
                                alu_op_o = ALU_SRA;   
                            default: begin
                                gpr_we_o = 'b0;       
                                b_sel_o  = 'b0;
                                illegal_instr_o = 1;
                            end
                        endcase                
                    end
                    3'b110: 
                        alu_op_o = ALU_OR;
                    3'b111: 
                        alu_op_o = ALU_AND;
                endcase
            end        
            7'b0000011: begin
                // imm = fetched_instr_i[31:20];
                mem_req_o = 'b1;
                gpr_we_o  = 'b1;
                b_sel_o   = 'b1;
                alu_op_o  = ALU_ADD;
                wb_sel_o  = 'b1;
                case(funct3)
                    3'b000: // LB
                        mem_size_o = 3'd0;
                    3'b001: // LH
                        mem_size_o = 3'd1;
                    3'b010: // LW
                        mem_size_o = 3'd2;
                    3'b100: // LBU
                        mem_size_o = 3'd4;
                    3'b101: // LHU                    
                        mem_size_o = 3'd5;
                    default: begin
                        mem_req_o = 'b0;
                        gpr_we_o  = 'b0;
                        illegal_instr_o = 1;
                    end
                endcase
            end
            7'b0100011: begin
                mem_req_o = 'b1;
                mem_we_o  = 'b1;
                b_sel_o   = 'b011;
                alu_op_o  = ALU_ADD;
                case(funct3)
                    3'b000: // SB
                        mem_size_o = 3'd0;
                    3'b001: // SH
                        mem_size_o = 3'd1;
                    3'b010: // SW
                        mem_size_o = 3'd2;
                    default: begin
                        mem_req_o = 'b0;
                        mem_we_o  = 'b0;
                        illegal_instr_o = 1;
                    end
                endcase
            end
            7'b1100011: begin
                branch_o = 'b1;
                case(funct3)
                    3'b000: // BEQ
                        alu_op_o = ALU_EQ;
                    3'b001: // BNE
                        alu_op_o = ALU_NE;
                    3'b100: // BLT
                        alu_op_o = ALU_LTS;
                    3'b101: // BGE
                        alu_op_o = ALU_GES;
                    3'b110: // BLTU
                        alu_op_o = ALU_LTU;
                    3'b111: // BGEU
                        alu_op_o = ALU_GEU;
                    default: begin
                        branch_o = 'b0;
                        illegal_instr_o = 1;
                    end
                endcase
            end
            7'b1101111: begin //JAL
                    jal_o = 1;
                    a_sel_o = 1;
                    b_sel_o = 'b100;
                    alu_op_o = ALU_ADD;
                    gpr_we_o = 1;
                end            
            7'b1100111: begin //JALR                    
                    case(funct3)
                        3'b000: begin
                            jalr_o = 1;
                            a_sel_o = 1;
                            b_sel_o = 'b100;
                            alu_op_o = ALU_ADD;
                            gpr_we_o = 1;
                        end
                        default:
                            illegal_instr_o = 1;
                    endcase
                end
            7'b0110111: begin// LUI
                    a_sel_o = 'b10;
                    b_sel_o = 'b010;
                    gpr_we_o = 'b1;
                    alu_op_o = ALU_ADD;                     
                end
            7'b0010111: begin //AUIPC
                    a_sel_o = 'b01;
                    b_sel_o = 'b010;
                    gpr_we_o = 'b1;
                    alu_op_o = ALU_ADD;
                end
            7'b0001111: begin
                case(funct3)
                    3'b000: ; // FENCE
                    default:
                        illegal_instr_o = 1;
                endcase
            end
            7'b1110011: begin       
                csr_we_o = 'b1;
                gpr_we_o = 'b1;
                wb_sel_o = 'b10;
                csr_we_o = 'b1;    
                case(funct3)   
                    3'b000: begin 
                        csr_we_o = 'b0;
                        gpr_we_o = 'b0;
                        wb_sel_o = 'b0;
                        csr_we_o = 'b0;  
                        case(fetched_instr_i)
                            32'b00110000001000000000000001110011:
                                mret_o = 'b1; // MRET
                            default: begin
                                illegal_instr_o = 'b1; // EBREAK / ECALL
                            end     
                        endcase   
                    end            
                    3'b001:
                        csr_op_o = CSR_RW;  // CSRRW
                    3'b010:
                       csr_op_o = CSR_RS;   // CSRRS
                    3'b011:
                        csr_op_o = CSR_RC;  // CSRRC   
                    3'b101:
                        csr_op_o = CSR_RWI; // CSRWI
                    3'b110:
                        csr_op_o = CSR_RSI; // CSRSI                        
                    3'b111:
                        csr_op_o = CSR_RCI; // CSRCI
                    default: begin
                        csr_we_o = 'b0;
                        gpr_we_o = 'b0;
                        wb_sel_o = 'b0;
                        csr_we_o = 'b0; 
                        illegal_instr_o = 'b1;
                    end
                endcase
            end 
            default: 
                illegal_instr_o = 1;
        endcase        
    end    
endmodule
