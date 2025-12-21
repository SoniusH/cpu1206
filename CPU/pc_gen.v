`timescale 1ns/1ps
// this module generates the program counter (PC) value
// may be changed to support jump and branch instructions, 
// as well as stalling and pipeline flushing later
`include "defines.vh"
module pc_gen (
    input wire clk,
    input wire rst,
    input wire work_ena,
    input wire stall,
    input wire pc_jump , 
    input wire [`PC_WIDTH-1:0] pc_target,
    output reg [`PC_WIDTH-1:0] pc
);
    always @(posedge clk) begin
        if (rst) begin
            pc <= {`PC_WIDTH{1'b0}}; // Reset PC to 0
        end 
        else if (!work_ena)
            pc <= `PC_WIDTH'd4 ;
        else if (pc_jump) begin
            pc <= pc_target + 3'b100; // Update PC to branch target
        end
        else if (stall)
            pc <= pc ;   
        else begin
            pc <= pc + 4; // Increment PC by 4 for next instruction
        end
    end
endmodule