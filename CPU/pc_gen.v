`timescale 1ns/1ps
// this module generates the program counter (PC) value
// may be changed to support jump and branch instructions, 
// as well as stalling and pipeline flushing later
`include "defines_bitwidth.vh"
module pc_gen (
    input wire clk,
    input wire rst,
    //input wire [`PC_WIDTH-1:0] branch_target,
    output reg [`PC_WIDTH-1:0] pc
);
    always @(posedge clk) begin
        if (rst) begin
            pc <= {`PC_WIDTH{1'b0}}; // Reset PC to 0
        //end else if (branch) begin
            //pc <= branch_target; // Update PC to branch target
        end else begin
            pc <= pc + 1; // Increment PC by 1 for next instruction
        end
    end
endmodule