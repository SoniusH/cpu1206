`timescale 1ns/1ps
/*
    This module manages multipliers with pipelining.

*/
`include "defines.vh"
module mult_manager(
    input wire clk,
    input wire rst,
    // inputs
    // multiplier operands
    input wire [31:0] A,
    input wire [31:0] B,
    // multiplier type
    input wire [1:0] mult_type, //00: SxS, 01: SxU, 10: UxU
    input wire [4:0] rd_addr_i, // destination reg addr

    output wire rd_data, // multiplier result
    output wire rd_data_2, // used in the case of 2 consecutive instructions of the same operands, 
                            //for upper 32 bits of result
    output reg [4:0] rd_addrs [`MULT_PPL_STAGE-1:0] // destination reg addrs in pipeline
);
    // instantiate multipliers
    `MULT_MODULE_NAME_SxS u_mult_sxs(
        .clk(clk), .en(1'b1),
        .A(A), .B(B), .P()
    );
    `MULT_MODULE_NAME_SxU u_mult_sxu(
        .clk(clk), .en(1'b1),
        .A(A), .B(B), .P()
    );
    `MULT_MODULE_NAME_UxU u_mult_uxu(
        .clk(clk), .en(1'b1),
        .A(A), .B(B), .P()
    );
    // pipeline reg for rd_addrs
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addrs[i] <= 5'b0;
            end
        end else begin
            rd_addrs[0] <= rd_addr_i;
            for (i = 1; i < `MULT_PPL_STAGE; i = i + 1) begin
                rd_addrs[i] <= rd_addrs[i-1];
            end
        end
    end

endmodule