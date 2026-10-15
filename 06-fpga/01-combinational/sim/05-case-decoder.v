// decoder2to4.v
module decoder2to4 (
    input  wire [1:0] a,
    output reg  [3:0] y
);
    always @(*) begin
        case (a)
            2'd0:    y = 4'b0001;
            2'd1:    y = 4'b0010;
            2'd2:    y = 4'b0100;
            2'd3:    y = 4'b1000;
            default: y = 4'b0000;
        endcase
    end
endmodule
