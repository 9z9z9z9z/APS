`timescale 1ns / 1ps

module riscv_unit(
        input logic         clk_i,
        input logic         rst_i,
        
        input logic [15:0]  sw_i,
        input logic         kclk_i,
        input logic         kdata_i,
        input logic         rx_i,        
        
        
        output logic [15:0] led_o,
        output logic [ 6:0] hex_led_o,
        output logic [ 7:0] hex_sel_o,
        output logic        tx_o,
        output logic [ 3:0] vga_r_o,
        output logic [ 3:0] vga_g_o,
        output logic [ 3:0] vga_b_o,
        output logic        vga_hs_o,
        output logic        vga_vs_o
    );
           
    logic           irq_req;
    logic           irq_ret;
    logic [31:0]    instr_addr;
    logic [31:0]    instr;
    logic           core_req;
    logic           core_we;
    logic [2 :0]    core_size;
    logic [31:0]    core_wd;
    logic [31:0]    core_addr;
    
    logic           core_stall;
    logic [31:0]    core_rd;
    logic [31:0]    mem_rd;
    logic [31:0]    ext_mem_rd;
    logic           mem_ready;
    logic           mem_we;
    logic [3 :0]    mem_be;
    logic [31:0]    mem_wd;
    logic [31:0]    mem_addr;
    
    logic [255:0]   out;
    logic [ 31:0]   ext_addr;
    logic           ext_mem_req;
    logic           ps2_req;
    logic           vga_req;
    logic [31:0]    ps2_rd;
    logic [31:0]    vga_rd;
    
    logic sysclk, rst;
    
    assign ext_addr         = {8'b0, mem_addr[23:0]};
    assign out              = 255'b1 << mem_addr[31:24];
    assign ext_mem_req      = out[0] & req;
    assign ps2_req          = out[3] & req;
    assign vga_req          = out[7] & req;
    
    
    always_comb begin
        case (mem_addr[31:24])
            'b000: mem_rd = ext_mem_rd;
            'b011: mem_rd = ps2_rd;
            'b111: mem_rd = vga_rd;
            default: mem_rd = ext_mem_rd; 
        endcase
    end
        
    // Divider
    sys_clk_rst_gen divider(
        .ex_clk_i(clk_i),
        .ex_areset_n_i(rst_i),
        .div_i(5),
        
        .sys_clk_o(sysclk),
        .sys_reset_o(rst)
    );
    
    instr_mem InstrMemory(
        .addr_i(instr_addr),
        .read_data_o(instr)
    );
    
    // Controls
    ps2_sb_ctrl ps2(
        .clk_i(sysclk),
        .rst_i(rst),
        .addr_i(ext_addr),
        .req_i(ps2_req),
        .write_data_i(mem_wd),
        .write_enable_i(mem_we),
        .interrupt_return_i(irq_ret),              
        .kclk_i(kclk_i),
        .kdata_i(kdata_i),
        
        .read_data_o(ps2_rd),
        .interrupt_request_o(irq_req)        
    );
    
    vga_sb_ctrl vga(
        .clk_i(sysclk),
        .rst_i(rst),
        .clk100m_i(clk_i),
        .req_i(vga_req),
        .write_enable_i(mem_we),
        .mem_be_i(mem_be),
        .addr_i(ext_addr),
        .write_data_i(mem_wd),
        
        .read_data_o(vga_rd),
        .vga_r_o(vga_r_o),
        .vga_g_o(vga_g_o),
        .vga_b_o(vga_b_o),
        .vga_hs_o(vga_hs_o),
        .vga_vs_o(vga_vs_o)        
    );
    
    riscv_core core(
        .clk_i(sysclk),
        .rst_i(rst),
        .instr_i(instr),
        .mem_rd_i(core_rd),
        .stall_i(core_stall),
        .irq_req_i(irq_req),
        
        .instr_addr_o(instr_addr),
        .mem_req_o(core_req),
        .mem_we_o(core_we),
        .mem_size_o(core_size),
        .mem_wd_o(core_wd),
        .mem_addr_o(core_addr),
        .irq_ret_o(irq_ret)
    );
    
    riscv_lsu LSU(
        .clk_i(sysclk),
        .rst_i(rst),
        .core_req_i(core_req),
        .core_we_i(core_we),
        .core_size_i(core_size),
        .core_wd_i(core_wd),
        .core_addr_i(core_addr),
        .mem_ready_i(1'b1),
        .mem_rd_i(mem_rd),
        
        .core_stall_o(core_stall),
        .core_rd_o(core_rd),
        .mem_req_o(req),
        .mem_we_o(mem_we),
        .mem_be_o(mem_be),
        .mem_wd_o(mem_wd),
        .mem_addr_o(mem_addr)                
    );
    
    ext_mem DataMemory(
        .clk_i(sysclk),
        .mem_req_i(ext_mem_req),
        .write_enable_i(mem_we),
        .byte_enable_i(mem_be),
        .write_data_i(mem_wd),
        .addr_i(mem_addr),
        
        .ready_o(mem_ready),
        .read_data_o(ext_mem_rd)
    );
    
    
    
endmodule
