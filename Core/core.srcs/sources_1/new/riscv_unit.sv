`timescale 1ns / 1ps

module riscv_unit(
        input logic clk_i,
        input logic rst_i
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
    logic           mem_ready;
    logic           mem_req;
    logic           mem_we;
    logic [3 :0]    mem_be;
    logic [31:0]    mem_wd;
    logic [31:0]    mem_addr;
    
    
    
    instr_mem InstrMemory(
        .addr_i(instr_addr),
        .read_data_o(instr)
    );
    
    riscv_core core(
        .clk_i(clk_i),
        .rst_i(rst_i),
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
        .clk_i(clk_i),
        .rst_i(rst_i),
        .core_req_i(core_req),
        .core_we_i(core_we),
        .core_size_i(core_size),
        .core_wd_i(core_wd),
        .core_addr_i(core_addr),
        .mem_ready_i(mem_ready),
        .mem_rd_i(mem_rd),
        
        .core_stall_o(core_stall),
        .core_rd_o(core_rd),
        .mem_req_o(mem_req),
        .mem_we_o(mem_we),
        .mem_be_o(mem_be),
        .mem_wd_o(mem_wd),
        .mem_addr_o(mem_addr)                
    );
    
    ext_mem DataMemory(
        .clk_i(clk_i),
        .mem_req_i(mem_req),
        .write_enable_i(mem_we),
        .byte_enable_i(mem_be),
        .write_data_i(mem_wd),
        .addr_i(mem_addr),
        
        .ready_o(mem_ready),
        .read_data_o(mem_rd)
    );
    
endmodule
