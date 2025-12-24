`timescale 1ns/1ps
module decoder5_32(
    input [4:0] in5,
    output [31:0] out32
);
    assign out32 = 32'b1 << in5;
endmodule