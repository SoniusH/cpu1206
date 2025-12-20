module bram_adapter (
    input  wire clk,
    input  wire rst,
    input  wire en_i,    
    input  wire we_i, 
    input  wire [31:0]addr_i,  
    input  wire [31:0]din_i,  
    input  wire [3:0]mask_i,

    output reg [31:0]dout_o,
    output reg ram_busy_o,
    output reg ram_done_o 
);

    reg [1:0] state;
    localparam IDLE = 2'b00;
    localparam REQ = 2'b01; // Request phase
    localparam WAIT = 2'b10;
    localparam DONE = 2'b11; // Data is valid phase

    wire bram_ena;
    wire bram_wea;
    wire bram_regcea;
    wire [31:0] bram_addra;
    wire [31:0] bram_dina;
    wire [3:0] bram_wea_mask;
    wire [31:0] bram_douta;


    blk_mem_gen_0 your_bram_inst (
        .clka    (clk),
        .ena     (bram_ena),
        .wea     (bram_wea_mask),
        .addra   (bram_addra),
        .dina    (bram_dina),
        .regcea  (bram_regcea), 
        .douta   (bram_douta)
    );

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            ram_busy_o <= 1'b0;
            ram_done_o <= 1'b0;
            dout_o <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    ram_busy_o <= 1'b0;
                    ram_done_o <= 1'b0;
                    
                    if (en_i) begin
                        state <= REQ;
                        ram_busy_o <= 1'b1;
                        ram_done_o <= 1'b0;
                    end
                end

                REQ: begin
                    state <= WAIT;
                    ram_busy_o <= 1'b1;
                    ram_done_o <= 1'b0;
                end
                
                WAIT:  begin
                    state <= DONE;
                    ram_busy_o <= 1'b1;
                    ram_done_o <= 1'b0;
                end
                
                DONE: begin
                    if (!we_i) begin
                        dout_o <= bram_douta;
                    end
                    state <= IDLE;
                    ram_busy_o <= 1'b0;
                    ram_done_o <= 1'b1; 
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    assign bram_ena = (state != IDLE);
    assign bram_regcea = (state == DONE);
    assign bram_addra = addr_i;
    assign bram_dina = din_i;
    assign bram_wea_mask = (we_i) ? mask_i : 4'b0;

endmodule