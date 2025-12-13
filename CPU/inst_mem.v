`timescale 1ns/1ps
module inst_mem (
    input wire clk,
    input wire rst,

//    input wire we,
//    input wire [4:0] waddr,
//    input wire [31:0] wdata,

    input wire re,
    input wire [9:0] raddr, //temporary 10 bits for 1024 depth
    output wire [31:0] rdata,

//    input wire re2,
//    input wire [4:0] raddr2,
//    output wire [31:0] rdata2
);
    reg [31:0] regfile [1023:0];
    // Read operation
    assign rdata = (re) ? regfile[raddr] : 32'b0;
endmodule