`timescale 1ns/1ps
`include "defines_bitwidth.vh"
module inst_mem (
    input wire clka,
//    input wire we,
//    input wire [4:0] waddr,
//    input wire [31:0] wdata,

    input wire rea,
    input wire [`PC_WIDTH-1:0] addra, //temporary 10 bits for 1024 depth
    output wire [31:0] douta,

//    input wire re2,
//    input wire [4:0] raddr2,
//    output wire [31:0] rdata2
);
    reg [31:0] regfile [1023:0];
    // Read operation
    assign douta = (rea) ? regfile[addra] : 32'b0;
endmodule