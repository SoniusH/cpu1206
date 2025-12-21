`define OP_I_LOAD 7'b0000011
`define OP_S 7'b0100011
module MEM (
    input wire rst,

    input wire rd_we_i,
    input wire [4:0] rd_addr_i,
    input wire [31:0] rd_data_i,

    input wire [6:0] aluop_i,

    input wire [31:0] ram_data_i,    // data read from ram
    
    output reg rd_we,
    output reg [4:0] rd_addr,
    output reg [31:0] rd_data
);
    
    always @(*) begin
        if (rst == 1) begin
            rd_we <= 0;
            rd_addr <= 5'b0;
            rd_data <= 32'b0;
        end else begin
            case (aluop_i)
                //store instrument logic
                `OP_S : begin
                    rd_we <= rd_we_i;
                    rd_addr <= rd_addr_i;
                    rd_data <= rd_data_i;
                end
                //load instrument logic
                `OP_I_LOAD : begin
                    rd_we <= rd_we_i;
                    rd_addr <= rd_addr_i;
                    rd_data <= ram_data_i;
                end    
            endcase   
        end 
    end               
endmodule