`timescale 1ns / 1ps

module ps2_sb_ctrl(
        input logic         clk_i,
        input logic         rst_i,
        input logic [31:0]  addr_i,
        input logic         req_i,
        input logic [31:0]  write_data_i,
        input logic         write_enable_i,        
        input logic         interrupt_return_i,
        input logic         kclk_i,
        input logic         kdata_i,        
        
        output logic [31:0] read_data_o,        
        output logic        interrupt_request_o        
    );
    
    logic       keycode_valid;
    logic [7:0] keycode_out;
    logic       read_req;
    logic       write_req;
    
    logic [7:0] scan_code;
    logic       scan_code_is_unread;
    
    assign read_req  = req_i & ~write_enable_i;
    assign write_req = req_i &  write_enable_i;
    assign interrupt_request_o = scan_code_is_unread; 
    
    
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            scan_code               <= 'b0;
            scan_code_is_unread     <= 'b0;
        end
        else if (addr_i == 32'h24 & write_req & write_data_i == 32'h1) begin
            scan_code               <= 'b0;
            scan_code_is_unread     <= 'b0;
        end
        else begin
            if (keycode_valid) begin
                scan_code           <= keycode_out;
                scan_code_is_unread <= 'b1;
            end
            if (read_req) begin
                if (addr_i == 32'h00) begin
                    read_data_o             <= {24'b0, scan_code};
                    if (~keycode_valid) begin
                        scan_code_is_unread <= 'b0;
                    end
                end
                else if (addr_i == 32'h04) begin
                    read_data_o <= {31'b0, scan_code_is_unread};
                end
            end
            if (interrupt_return_i & ~keycode_valid) begin
                scan_code_is_unread <= 'b0;
            end
        end
    end      
  
    PS2Receiver PS2(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .kclk_i(kclk_i),
        .kdata_i(kdata_i),
        
        .keycode_valid_o(keycode_valid),
        .keycodeout_o(keycode_out)
    );
    
endmodule
