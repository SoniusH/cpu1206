`timescale 1ns/1ps
/*
    *** As MDR can be cancelled, we only need 1 more set of registers. ***

    This module introduces a delay of 1 ~~2~~ clock cycles to the PC signal,
    to make PC match the instruction.
    Otherwise, the PC value would mismatch the instruction 
    in following stages.

    *** Pipeline flushing and stalling may be introduced later ***
    *** (currently NOT implemented) ***

    Schematic:
                DFF_set_1           DFF_set_2     
      PC_i      --------   PC_mid   --------        
    ------------|      |------------|      |------------PC_o
                |      |            |      |        
            clk-|>     |        clk-|>     |   
                --------            -------- 
                              BRAM
            ----------------------------------------
            |   --------------------------------   |
            |   |            memory            |   |
            |   --------------------------------   |
            |             addr|  |dout             |
      PC_i  |   ------------  |  |  ------------   |
    --------|---|          |---  ---|          |---|----instruction
     (addr) |   |  MAR(FF) |        |  MDR(FF) |   |
            | --|>         |     ---|>         |   |
            | | ------------     |  ------------   |
    clk-----|---------------------                 |
            ----------------------------------------

*/
`include "defines.vh"
module pc_delay (
    input wire clk,
    input wire rst,
    input wire [`PC_WIDTH-1:0] pc_i,
    output reg [`PC_WIDTH-1:0] pc_o
);
    always @(posedge clk) begin
        if(rst)begin
            pc_o <= {`PC_WIDTH{1'b0}};
        end else begin
            pc_o <= pc_i;
        end
    end
    /*
    reg [`PC_WIDTH-1:0] pc_mid;

    // First DFF_set    
    always @(posedge clk) begin
        if (rst) begin
            pc_mid <= {`PC_WIDTH{1'b0}};
        end else begin
            pc_mid <= pc_i;
        end
    end

    // Second DFF_set
    always @(posedge clk) begin
        if (rst) begin
            pc_o <= {`PC_WIDTH{1'b0}};
        end else begin
            pc_o <= pc_mid;
        end
    end
    */
endmodule