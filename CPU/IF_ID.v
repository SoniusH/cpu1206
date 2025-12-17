`timescale 1ns/1ps
`include "defines.vh"
module IF_ID(
    input wire clk,
    input wire rst,

    input wire [`PC_WIDTH-1:0]if_pc,
    input wire [31:0] if_inst,
    output wire [`PC_WIDTH-1:0]id_pc,
    output wire [31:0] id_inst
);
    always @(posedge clk) begin
        if(rst)begin
            id_inst <= 32'b0;
            id_pc <= 1'b0;
        end else begin
            id_inst <= if_inst;
            id_pc <= id_pc;
        end
    end
endmodule