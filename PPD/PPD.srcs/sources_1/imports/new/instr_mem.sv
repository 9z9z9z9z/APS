module instr_mem(
    input  logic [31:0] addr_i, 
    
    output logic [31:0] read_data_o
    );
    
    logic [31:0] ROM [0:1023];
    
    initial begin
        $readmemh("my_program.mem", ROM);
    end
    
    assign read_data_o = ROM[addr_i[11:2]];
        
endmodule
