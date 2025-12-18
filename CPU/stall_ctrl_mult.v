`timescale 1ns/1ps
`include "defines.vh"
/*
    This module generates stalling control signal for multiplication operations.
    It generates stall signals based on the status of the multiplication unit
    and current instruction in the ID stage of the pipeline to prevent Data Hazard.
*/
module stall_ctrl_mult(
    input wire clk,
    input wire rst,
    // from mult_manager
    input wire [4:0] rd_addrs_mult_i [`MULT_PPL_STAGE-1:0], // rd from mult_manager
    input wire [`MULT_PPL_STAGE-1:0] mult_uses_i, // use signal from mult_manager
    // from ID stage
    // rs1
    input wire rs1_re_id_i, 
    input wire [4:0] rs1_addr_id_i,
    // rs2
    input wire rs2_re_id_i, 
    input wire [4:0] rs2_addr_id_i,
    // rd
    input wire rd_we_id_i, 
    input wire [4:0] rd_addr_id_i,
    // to pipeline control
    output reg stall // stall signal to pipeline control
);
    // Define opcode for multiplication instructions
    //localparam OPCODE_MUL = 7'b0110011; // R-type opcode for multiplication
    integer i;
    always @(*) begin
        stall = 1'b0;
        // Check for data hazards with multiplication unit
        for (i = 0; i < `MULT_PPL_STAGE; i = i + 1) begin
            if (mult_uses_i[i]) begin
                // as addrs are 0 when not used, 
                // and rd_addr_i==0 only when !uses_i[i],
                // as mult_manager itself does not accept rd_addr_i==0,
                // no need to check for 0 here
                if (rs1_addr_id_i == rd_addrs_mult_i[i]
                  ||rs2_addr_id_i == rd_addrs_mult_i[i]
                  ||rd_addr_id_i == rd_addrs_mult_i[i]) begin
                    stall = 1'b1;
                end
                /*
                // Check rs1
                if (rs1_re_id_i && (rs1_addr_id_i == rd_addrs_mult_i[i])) begin
                    stall = 1'b1;
                end
                // Check rs2
                if (rs2_re_id_i && (rs2_addr_id_i == rd_addrs_mult_i[i])) begin
                    stall = 1'b1;
                end
                // Check rd
                if (rd_we_id_i && (rd_addr_id_i == rd_addrs_mult_i[i])) begin
                    stall = 1'b1;
                end
                */
            end
        end
    end
endmodule