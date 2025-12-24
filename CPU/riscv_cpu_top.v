`timescale 1ns/1ps
`include "defines.vh"
module riscv_cpu_top(
    input wire clk,
    input wire rst_n,
    
    input wire btnC,
    input wire btnU,
    input wire btnL,
    input wire btnR,
    input wire btnD,
    
    output wire [6:0] seg,
    output wire dp,
    output wire [3:0] an
);    
    wire work_ena;
    // pc to inst_mem
    wire [`PC_WIDTH-1:0] pc;
    wire [31:0] inst;
    // to data_mem, read
    wire data_mem_re;
    //output wire [4:0] data_mem_addr_r,
    wire [31:0] data_mem_data_r_unext;
    wire [31:0] data_mem_data_r;
    wire data_mem_sign_ext_r;
    // to data_mem, write
    wire data_mem_we;
    //output wire [4:0] data_mem_addr_w,
    wire [31:0] data_mem_data_w;
    // to data_mem, shared
    // as we cannot read and write at the same time
    wire [3:0] data_mem_mask_wr;
    wire [4:0] data_mem_addr_wr;
    
    wire rst;
    assign rst = ~rst_n;
    cpu u_cpu(
        .clk(clk),.rst(rst),
        .work_ena(work_ena),.pc(pc),.inst(inst),
        .data_mem_re(data_mem_re),.data_mem_data_r(data_mem_data_r),.data_mem_sign_ext_r(data_mem_sign_ext_r),
        .data_mem_we(data_mem_we),.data_mem_data_w(data_mem_data_w),
        .data_mem_mask_wr(data_mem_mask_wr),.data_mem_addr_wr(data_mem_addr_wr)
    );
    `INST_MEM_MODULE_NAME inst_mem(.clka(clk),.ena(),.addra(pc),.douta(inst));
    `DATA_MEM_MODULE_NAME data_mem(
        .clka(clk),.ena(data_mem_we),.addra(data_mem_addr_wr),.dina(data_mem_data_w),.wea(data_mem_mask_wr),
        .clkb(clk),.enb(data_mem_re),.addrb(data_mem_addr_wr),.doutb(data_mem_data_r_unext)
    );
    ram_r_data_ext u_ram_sign_ext(
        .ram_r_data_i(data_mem_data_r_unext),.ram_r_mask(data_mem_mask_wr),
        .ram_r_sign_ext(data_mem_sign_ext_r),.ram_r_data_o(data_mem_data_r)
    );
    
    outer_device u_outer_device(
        .clk(clk),.rst(rst),
        .button(btnC),.u_button(btnU),.l_button(btnL),.r_button(btnR),.d_button(btnD),
        .seg_an(an),.seg_seg({dp,seg}),.work_ena(work_ena),.ce()
    );
endmodule