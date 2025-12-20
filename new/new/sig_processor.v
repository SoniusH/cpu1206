module signal_detector (
    input wire clk,
    input wire sig,
    output reg valid
);
    reg [3:0]count;
    always @(posedge clk)
        begin
            if (!sig)
                count <= 3'b0;    //to present the end of a piece of signal
            else if (count <= 3'd5)
                count <= count + 1;   //count add up when the posedge of clk comes
        end
    always @(*)
        valid <= (count == 3'd5);  //valid works when count counts 5
endmodule