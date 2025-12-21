module mode_sel (
    input wire clk,
    input wire rst,
    input wire button,
    input wire u_button,
    input wire d_button,
    input wire [15:0]pre_data,
    input wire [15:0]fin_data,
    
    output reg [15:0]data,
    output reg work_ena,
    output reg ce
//    output reg [31:0]addr
);
    
    reg [1:0]state;
    localparam IDLE = 2'b00;
    localparam DATA_IN = 2'b01;
    localparam WORK = 2'b10;
    localparam DATA_OUT =2'b11;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data <= 16'habcd;
            work_ena <= 0;
            ce <= 0;
//            addr <= 32'b0;
        end else begin
            case (state)
                IDLE : begin
                    data <= 16'habcd;
                    work_ena <= 1'b0;
                    ce <= 1'b0;
//                    addr <= 32'b0;
                    if (button) begin state <= DATA_IN; end
                end
                DATA_IN : begin
                    data <= pre_data;
                    work_ena <= 1'b0;
                    ce <= 1'b0;
//                    addr <= 32'b0;
                    if (button) begin state <= WORK; end
                end
                WORK : begin
                    data <= 16'heeee;
                    work_ena <= 1'b1;
                    ce <= 1'b0;
//                    addr <= 32'b0;
                    if (button) begin state <= DATA_OUT; end
                end
                DATA_OUT : begin
                    data <= fin_data;
                    work_ena <= 1'b0;
                    ce <= 1'b1;
/*                    if (u_button) begin
                        addr <= addr + 4;
                    end else if (d_button) begin
                        if (addr != 32'b0) begin
                            addr <= addr -4;
                        end
                    end    */
                    if (button) begin state <= IDLE; end
                end
            endcase
        end
    end
endmodule