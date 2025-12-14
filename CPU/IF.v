`timescale 1ns/1ps
`include "defines_bitwidth.vh"
module IF (
    //input wire clk,
    input wire rst,
    //input wire branch,
    //input wire [31:0] branch_target,
    input wire [31:0] inst_i,
    output reg [`PC_WIDTH-1:0] pc,
    output wire [31:0] inst
);

    always @(posedge clk) begin
        if (rst) begin
            pc <= 10'b0; // Reset PC to 0
        end else begin
            pc <= pc + 1; // Increment PC by 1 for next instruction
        end
    end
    assign inst = inst_i;
endmodule
