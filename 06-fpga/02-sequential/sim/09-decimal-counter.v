// bcd_digit.v
module bcd_digit (
    input            clk,
    input            rst,
    input            en,
    output reg [3:0] q,
    output           carry
);
    assign carry = en && (q == 4'd9);

    always @(posedge clk)
        if (rst)     q <= 4'd0;
        else if (en) q <= (q == 4'd9) ? 4'd0 : q + 4'd1;
endmodule

// bcd2.v
module bcd2 (
    input        clk,
    input        rst,
    input        en,
    output [3:0] ones,
    output [3:0] tens,
    output       carry
);
    wire c0;

    bcd_digit d0 (.clk(clk), .rst(rst), .en(en), .q(ones), .carry(c0));
    bcd_digit d1 (.clk(clk), .rst(rst), .en(c0), .q(tens), .carry(carry));
endmodule

// seg7.v
module seg7 (
    input      [3:0] d,
    output reg [6:0] seg
);
    always @(*)
        case (d)
            4'd0:    seg = 7'b0111111;
            4'd1:    seg = 7'b0000110;
            4'd2:    seg = 7'b1011011;
            4'd3:    seg = 7'b1001111;
            4'd4:    seg = 7'b1100110;
            4'd5:    seg = 7'b1101101;
            4'd6:    seg = 7'b1111101;
            4'd7:    seg = 7'b0000111;
            4'd8:    seg = 7'b1111111;
            4'd9:    seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
endmodule

// stopwatch.v
module stopwatch #(
    parameter CLK_HZ = 27_000_000
) (
    input        clk,
    input        rst,
    output [6:0] seg_ones,
    output [6:0] seg_tens
);
    localparam LAST = CLK_HZ - 1;
    localparam W    = (CLK_HZ > 1) ? $clog2(CLK_HZ) : 1;

    reg [W-1:0] cnt;
    wire        tick = (cnt == LAST[W-1:0]);
    wire [3:0]  ones;
    wire [3:0]  tens;
    wire        unused_carry;

    always @(posedge clk)
        if (rst || tick) cnt <= {W{1'b0}};
        else             cnt <= cnt + 1'b1;

    bcd2 sec (.clk(clk), .rst(rst), .en(tick), .ones(ones), .tens(tens), .carry(unused_carry));
    seg7 s0 (.d(ones), .seg(seg_ones));
    seg7 s1 (.d(tens), .seg(seg_tens));
endmodule
