`timescale 1ns / 1ps

module vga_sb_ctrl(
        input  logic         clk_i,
        input  logic         rst_i,
        input  logic         clk100m_i,
        input  logic         req_i,
        input  logic         write_enable_i,
        input  logic [ 3:0]  mem_be_i,
        input  logic [31:0]  addr_i,
        input  logic [31:0]  write_data_i,
        
        output logic [31:0]  read_data_o,
        output logic [ 3:0]  vga_r_o,
        output logic [ 3:0]  vga_g_o,
        output logic [ 3:0]  vga_b_o,
        output logic         vga_hs_o,
        output logic         vga_vs_o
    );
    
    logic [31:0] char_map_rdata;
    logic [31:0] col_map_rdata;
    logic [31:0] char_tiff_rdata;
    
    assign read_data_o = (addr_i[13:12] == 2'b00) ? char_map_rdata : (
                             (addr_i[13:12] == 2'b01) ? col_map_rdata  : (
                                (addr_i[13:12] == 2'b10) ? char_tiff_rdata : char_map_rdata
                            )
                         );
    
    vgachargen VGA(
        // inputs
        .clk_i(clk_i),   // 
        .rst_i(rst_i),
        .clk100m_i(clk100m_i),
        
        .char_map_wdata_i(  write_data_i ),
        .col_map_wdata_i(   write_data_i ),
        .char_tiff_wdata_i( write_data_i ),
        
        .char_map_addr_i(   addr_i[11:2] ),
        .col_map_addr_i(    addr_i[11:2] ),
        .char_tiff_addr_i(  addr_i[11:2] ),
        
        .char_map_be_i(     mem_be_i     ),
        .col_map_be_i(      mem_be_i     ),
        .char_tiff_be_i(    mem_be_i     ),
        
        .char_map_we_i(
            (addr_i[13:12] == 2'b00) ? write_enable_i : 'b0
        ),
        .col_map_we_i(
            (addr_i[13:12] == 2'b01) ? write_enable_i : 'b0
        ),
        .char_tiff_we_i(
            (addr_i[13:12] == 2'b10) ? write_enable_i : 'b0
        ),
        
        // outputs        
        .char_map_rdata_o(char_map_rdata),
        .col_map_rdata_o(col_map_rdata),
        .char_tiff_rdata_o(char_tiff_rdata),
        .vga_r_o(vga_r_o),
        .vga_g_o(vga_g_o),
        .vga_b_o(vga_b_o),
        .vga_hs_o(vga_hs_o),
        .vga_vs_o(vga_vs_o)
    );
    
endmodule
