// 比べるための回路。チャタリングを取らず、btn_n の立ち下がりをそのまま数える
module top_raw (
    input        clk,
    input        rst_n,
    input        btn_n,
    output [6:0] seg
);
    reg [2:0] sync;
    reg [3:0] n;
    wire press = sync[2] & ~sync[1];

    always @(posedge clk)
        if (!rst_n) begin
            sync <= 3'b111;
            n    <= 4'h0;
        end else begin
            sync <= {sync[1:0], btn_n};
            if (press) n <= n + 4'h1;
        end

    seg7_decoder dec (.d(n), .seg(seg));
endmodule
