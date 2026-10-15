// 11-block-ram.v の ram を nextpnr で通すための包み。ピンの数を減らすため、
// 番地・書く値・we を 1 本のシフトレジスタ (si) で入れ、読んだ値は全ビットの排他的論理和 (so) にして 1 本で出す。
// ABITS と WIDTH は ram と同じ値を chparam で渡す。
module ramwrap #(
    parameter ABITS = 8,
    parameter WIDTH = 8
) (
    input  clk,
    input  si,
    output so
);
    reg [ABITS+WIDTH:0] sr;
    wire [WIDTH-1:0] dout;

    always @(posedge clk) sr <= {sr[ABITS+WIDTH-1:0], si};

    ram #(.ABITS(ABITS), .WIDTH(WIDTH)) u (
        .clk(clk), .we(sr[ABITS+WIDTH]),
        .addr(sr[ABITS+WIDTH-1:WIDTH]), .din(sr[WIDTH-1:0]), .dout(dout)
    );

    assign so = ^dout;
endmodule
