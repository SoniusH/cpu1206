module ram_r_data_ext (
    input wire [31:0]ram_r_data_i,
    input wire [3:0]ram_r_mask,
    input wire ram_r_sign_ext,
    
    output reg [31:0]ram_r_data_o
);
    always @(*) begin
        case (ram_r_sign_ext)
            //unsigned extension
            1'b0 : begin case (ram_r_mask)
                4'b1111 : ram_r_data_o <= {ram_r_data_i[7:0], ram_r_data_i[15:8], ram_r_data_i[23:16], ram_r_data_i[31:24]};
                4'b1100 : ram_r_data_o <= {{16{1'b0}}, ram_r_data_i[23:16], ram_r_data_i[31:24]};
                4'b0011 : ram_r_data_o <= {{16{1'b0}}, ram_r_data_i[7:0], ram_r_data_i[15:8]};
                4'b1000 : ram_r_data_o <= {{24{1'b0}}, ram_r_data_i[31:24]};
                4'b0100 : ram_r_data_o <= {{24{1'b0}}, ram_r_data_i[23:16]};
                4'b0010 : ram_r_data_o <= {{24{1'b0}}, ram_r_data_i[15:8]};
                4'b0001 : ram_r_data_o <= {{24{1'b0}}, ram_r_data_i[7:0]};
                default : ram_r_data_o <= 32'b0; endcase
            end
            //signed ectension
            1'b1 : begin case (ram_r_mask)
                4'b1100 : ram_r_data_o <= {{16{ram_r_data_i[23]}}, ram_r_data_i[23:16], ram_r_data_i[31:24]};
                4'b0011 : ram_r_data_o <= {{16{ram_r_data_i[7]}}, ram_r_data_i[7:0], ram_r_data_i[15:8]};
                4'b1000 : ram_r_data_o <= {{24{ram_r_data_i[31]}}, ram_r_data_i[31:24]};
                4'b0100 : ram_r_data_o <= {{24{ram_r_data_i[23]}}, ram_r_data_i[23:16]};
                4'b0010 : ram_r_data_o <= {{24{ram_r_data_i[15]}}, ram_r_data_i[15:8]};
                4'b0001 : ram_r_data_o <= {{24{ram_r_data_i[7]}}, ram_r_data_i[7:0]};
                default : ram_r_data_o <= 32'b0; endcase
            end
        endcase
    end
endmodule