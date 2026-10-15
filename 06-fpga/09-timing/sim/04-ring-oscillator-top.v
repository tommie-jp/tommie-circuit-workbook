// top_ring.v  リングオシレータを、1/2^K に分けて外へ出す
module top_ring #(
    parameter N = 5,           // リングの段数 (奇数)
    parameter K = 10           // 分周の段数 (出力は リングの周波数 / 2^K)
) (
    input  wire en,            // 36 番ピン。1 の間だけ発振する (AD3 の DIO1)
    output wire div_out        // 38 番ピン。AD3 の DIO0 で読む
);
    wire y;
    wire [K:0] c;              // c[0] がリングの出力。c[j] は c[j-1] の 1/2

    ring #(.N(N)) r (.en(en), .y(y));
    assign c[0] = y;

    genvar j;
    generate
        for (j = 0; j < K; j = j + 1) begin : div
            half h (.clk(c[j]), .q(c[j+1]));
        end
    endgenerate

    assign div_out = c[K];
endmodule
