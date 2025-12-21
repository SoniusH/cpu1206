module decoder_bcd_to_b (
    input wire [15:0]data_bcd,
    output reg [15:0]data_b
);
    //expanded data of each bit
    wire [15:0]ex_data_1, ex_data_10, ex_data_100, ex_data_1000;
    
    //true_value data of each bit
    wire [15:0]data_1, data_10, data_100, data_1000;
    
    assign ex_data_1 = {{12{1'b0}}, data_bcd[3:0]};
    assign ex_data_10 = {{12{1'b0}}, data_bcd[7:4]};
    assign ex_data_100 = {{12{1'b0}}, data_bcd[11:8]};
    assign ex_data_1000 = {{12{1'b0}}, data_bcd[15:12]};
    
    assign data_1 = ex_data_1;
    assign data_10 = (ex_data_10 << 3) + (ex_data_10 << 1);
    assign data_100 = (ex_data_100 << 6) + (ex_data_100 << 5) + (ex_data_100 << 2);
    assign data_1000 = (ex_data_1000 << 10) - (ex_data_1000 <<4) - (ex_data_1000 <<3);
    
    always @(*) begin
        data_b <= data_1 + data_10 + data_100 + data_1000;
    end

endmodule