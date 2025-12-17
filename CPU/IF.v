`timescale 1ns/1ps
// plan: seperate IF stage into 3 modules:
// 1. Instruction memory module (BRAM, simulate instruction memory)
// 2. PC delay module (to match instruction timing in pipeline)
// 3. PC generation module (to generate PC value)
// and directly connect them to IF_ID register set.
// therefore this module has been abandoned.
`include "defines.vh"
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
