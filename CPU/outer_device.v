module outer_device (
    input wire clk,
    input wire rst,
    input wire button,
    input wire u_button,
    input wire d_button,
    input wire l_button,
    input wire r_button,
    
    output wire [3:0]seg_an,
    output wire [7:0]seg_seg,
    output wire work_ena,
    output wire ce
//    output wire [31:0]addr_s
);
    
    wire button_v;
    wire u_button_v;
    wire d_button_v;
    wire l_button_v;
    wire r_button_v;
    wire [15:0]set_data;
    wire [1:0]set_dot;
    wire [15:0]display_data;
    
    signal_detector but (.clk(clk), .sig(button), .valid(button_v));
    signal_detector u_but (.clk(clk), .sig(u_button), .valid(u_button_v));
    signal_detector d_but (.clk(clk), .sig(d_button), .valid(d_button_v));
    signal_detector l_but (.clk(clk), .sig(l_button), .valid(l_button_v));
    signal_detector r_but (.clk(clk), .sig(r_button), .valid(r_button_v));
    
    num_set set (.clk(clk), .rst(rst),
        .up_button(u_button_v), .down_button(d_button_v),
        .h_button(l_button_v), .l_button(r_button_v),
        .data(set_data), .dot_seg(set_dot));
        
    mode_sel sel (.clk(clk), .rst(rst),
        .button(button_v), .u_button(u_button_v),
        .d_button(d_button_v), .pre_data(set_data),
        .fin_data(set_data), .data(display_data),
        .work_ena(work_ena), .ce(ce));//, .addr(addr_s)
        
    seg_display display (.clk(clk), .data(display_data),
        .dot_seg(set_dot), .seg_an(seg_an), .seg_seg(seg_seg));
    
endmodule