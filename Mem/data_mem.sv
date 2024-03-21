module data_mem(
        input  logic        clk_i,
        input  logic        mem_req_i,
        input  logic        write_enable_i,
        
        input  logic [31:0] addr_i,
        input  logic [31:0] write_data_i,
        
        output logic [31:0] read_data_o 
        );
        
        logic [31:0] memory [0:4095];
        
        // Sync reading 
        always_ff @(posedge clk_i) begin
            if (mem_req_i) begin
                read_data_o <= memory[addr_i[13:2]];
            end                
        end
        
        // Writing
        always_ff @(posedge clk_i) begin
            if (mem_req_i && write_enable_i) begin 
                    memory[addr_i[13:2]] <= write_data_i; 
            end
        end    
endmodule
