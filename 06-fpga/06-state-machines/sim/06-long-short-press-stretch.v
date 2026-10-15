// 1 クロックのパルスを N クロックに伸ばす。1 ms のパルスは目に見えないので、LED には 100 ms で出す
module pulse_stretch #(
    parameter N = 100
) (
    input  clk,
    input  rst,
    input  pulse,
    output out
);
    localparam W = $clog2(N + 1);
    localparam [W-1:0] LEN = N[W-1:0];

    reg [W-1:0] cnt;                         // 残りのクロック数

    always @(posedge clk)
        if (rst)                    cnt <= {W{1'b0}};
        else if (pulse)             cnt <= LEN;          // 来たら数え直す
        else if (cnt != {W{1'b0}})  cnt <= cnt - 1'b1;

    assign out = (cnt != {W{1'b0}});
endmodule
