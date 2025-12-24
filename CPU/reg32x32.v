`timescale 1ns/1ps
module reg32x32 (
    input wire clk,
    input wire rst,

    input wire we1,
    input wire [4:0] waddr1,
    input wire [31:0] wdata1,

    input wire we2,
    input wire [4:0] waddr2,
    input wire [31:0] wdata2,
    /*
    input wire we3,
    input wire [4:0] waddr3,
    input wire [31:0] wdata3,
*/
    input wire re1,
    input wire [4:0] raddr1,
    output wire [31:0] rdata1,

    input wire re2,
    input wire [4:0] raddr2,
    output wire [31:0] rdata2
);
    reg [31:0] regfile [31:0];
    wire [31:0] wflag1,wflag2;//,wflag3;
    decoder5_32 u1(.in5(waddr1),.out32(wflag1));
    decoder5_32 u2(.in5(waddr2),.out32(wflag2));
    //decoder5_32 u3(.in5(waddr3),.out32(wflag3));
    integer i;
    initial begin // only used for simulation, not synthesizable.
        for(i = 0; i < 32; i = i + 1)begin
            regfile[i] = i;
        end
    end
    // Write operation
    
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'b0;
            end
        end else begin //TODO: force x0 = 0
            // priority to mult/div write is to avoid write conflict
            for (i = 0; i < 32; i = i + 1)begin
                regfile[i] <= (wflag1[i] & we1) ? wdata1 :
                              (wflag2[i] & we2) ? wdata2 :
                              //(wflag3[i] & we3) ? wdata3 :
                              regfile[i];
            end
        end
    end
    // Read operations
    assign rdata1 = (re1) ? regfile[raddr1] : 32'b0;
    assign rdata2 = (re2) ? regfile[raddr2] : 32'b0;
endmodule