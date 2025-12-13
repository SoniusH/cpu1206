`timescale 1ns/1ps
module reg32x32 (
    input wire clk,
    input wire rst,

    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,

    input wire re1,
    input wire [4:0] raddr1,
    output wire [31:0] rdata1,

    input wire re2,
    input wire [4:0] raddr2,
    output wire [31:0] rdata2
);
    reg [31:0] regfile [31:0];

    // Write operation
    always @(posedge clk) begin
        if (rst) begin
            for (integer i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'b0;
            end
        end else if (we) begin //TODO: force x0 = 0
            regfile[waddr] <= wdata;
        end
    end
    // Read operations
    assign rdata1 = (re1) ? regfile[raddr1] : 32'b0;
    assign rdata2 = (re2) ? regfile[raddr2] : 32'b0;
endmodule