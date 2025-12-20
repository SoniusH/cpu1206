`timescale 1ns/1ps
module decoder_5_32(
    input wire [4:0] in,
    output wire [31:0] out
);
    assign out = 32'b1 << in;
endmodule