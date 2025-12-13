`timescale 1ns/1ps
module IF (
    input wire clk,
    input wire rst,
    //input wire branch,
    //input wire [31:0] branch_target,
    input wire [31:0] inst_i,
    output reg [31:0] pc,
    output wire [31:0] inst
);

    // Program Counter (PC) update logic
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'b0; // Reset PC to 0
        end else begin
            pc <= pc + 4; // Increment PC by 4 for next instruction
        end
    end

    // Fetch instruction from instruction memory
    assign inst = inst_i;
endmodule
