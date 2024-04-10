module CYBERcobra(
        input logic         clk_i,
        input logic         rst_i,        
        input logic [15:0]  sw_i,
        
        output logic [31:0] out_o
    );
    
    logic   [31:0]  PC;
    logic   [31:0]  read_instr;
    logic           rf_write_enable;
    logic   [4 :0]  rf_read_addr1;
    logic   [4 :0]  rf_read_addr2;
    logic   [4 :0]  rf_write_addr;
    logic   [31:0]  rf_write_data;
    logic   [31:0]  rf_alu_output;
    logic   [31:0]  rf_read_data1;
    logic   [31:0]  rf_read_data2;
    logic   [31:0]  adder_result;
    logic   [31:0]  adder_second_input;
    logic           alu_flag;
    logic           adder_carry;
    
    assign rf_write_enable = ~(read_instr[31] | read_instr[30]);
    assign rf_read_addr1 = read_instr[22:18];
    assign rf_read_addr2 = read_instr[17:13];
    assign rf_write_addr = read_instr[4:0];
    assign adder_carry = read_instr[31] | (read_instr[30] & alu_flag);
    
    assign out_o = rf_read_data1;
    
    // rf_write_data multyplexer
    always_comb begin
        case(read_instr[29:28])
            2'b00: rf_write_data = $signed(read_instr[27:5]);
            2'b01: rf_write_data = rf_alu_output;
            2'b10: rf_write_data = $signed(sw_i);
            2'b11: rf_write_data = 32'b0;
        endcase
    end
        
    // PC
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            PC = 32'b0;
        end
        else begin
           PC = adder_result;
       end
    end
        
    // adder_multyplexer
    always_comb begin
        case(adder_carry)
            2'b00: adder_second_input = 32'd4;
            2'b01: adder_second_input = $signed({read_instr[12:5], 2'b0});
        endcase
    end
    
    // Instruction memmory
    instr_mem imem(
        .addr_i(PC),
        
        .read_data_o(read_instr)
    );
    
    // ALU
    alu_riscv ALU(
        .a_i(rf_read_data1),
        .b_i(rf_read_data2),
        .alu_op_i(read_instr[27:23]),
        
        .flag_o(alu_flag),
        .result_o(rf_alu_output)            
    );
    
    // Register memory 
    rf_riscv reg_mem(
        .clk_i(clk_i),
        .write_enable_i(rf_write_enable),        
        .read_addr1_i(rf_read_addr1),
        .read_addr2_i(rf_read_addr2),        
        .write_addr_i(rf_write_addr),
        .write_data_i(rf_write_data),
        
        .read_data1_o(rf_read_data1),
        .read_data2_o(rf_read_data2)
    );
    
    // 32-bit adder
    fulladder32 adder(
        .a_i(PC),
        .b_i(adder_second_input),
        .carry_i('b0),
        .sum_o(adder_result)
    );
    
endmodule
