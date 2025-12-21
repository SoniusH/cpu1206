module WB(
    input wire rst,

    input wire rd_we_i,
    input wire [4:0] rd_addr_i,
    input wire [31:0] rd_data_i,

    output wire rd_we,
    output wire [4:0] rd_addr,
    output wire [31:0] rd_data
);
    assign rd_we = rst ? 1'b0 : rd_we_i;
    assign rd_addr = rst ? 5'b0 : rd_addr_i;
    assign rd_data = rst ? 32'b0 : rd_data_i;
endmodule