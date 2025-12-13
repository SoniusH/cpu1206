`timescale 1ns/1ps
module EX_MEM(
    input wire clk,
    input wire rst,
    // rd
    input wire rd_we_i,
    input wire [4:0] rd_addr_i,
    input wire [31:0] rd_data_i,
    
    output reg rd_we,
    output reg [4:0] rd_addr,
    output reg [31:0] rd_data
);
    always @(posedge clk) begin
        if(rst)begin
            rd_we <= 1'b0;
            rd_addr <= 5'b0;
            rd_data <= 32'b0;
        end else begin
            rd_we <= rd_we_i;
            rd_addr <= rd_addr_i;
            rd_data <= rd_data_i;
        end
    end
endmodule