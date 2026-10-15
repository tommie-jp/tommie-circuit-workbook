// UART の送信 (8N1)。start を 1 クロック 1 にすると data を送る。
// CLK_HZ を BAUD で割った数のクロックで 1 ビット。10 ビットのシフトレジスタを右へ送り、最下位をピンに出す
module uart_tx #(
    parameter CLK_HZ = 76_923,   // Pico 2 で 1 クロック 13 µs に固定したとき
    parameter BAUD   = 4800
) (
    input        clk,
    input        rst,
    input  [7:0] data,
    input        start,
    output       txd,
    output       busy
);
    localparam integer DIV  = (CLK_HZ + BAUD / 2) / BAUD;   // 1 ビットのクロック数 (四捨五入)
    localparam integer W    = (DIV > 1) ? $clog2(DIV) : 1;
    localparam integer LAST = DIV - 1;

    reg [9:0]   shreg;   // {ストップ, データ 8 ビット, スタート}。右へ送る
    reg [3:0]   nbits;   // 残りのビット数
    reg [W-1:0] cnt;     // 1 ビットの中のクロックを数える

    assign txd  = shreg[0];
    assign busy = (nbits != 4'd0);

    always @(posedge clk)
        if (rst) begin
            shreg <= 10'h3FF;                     // 何も送らない間は 1 (アイドル)
            nbits <= 4'd0;
            cnt   <= {W{1'b0}};
        end else if (!busy) begin
            if (start) begin
                shreg <= {1'b1, data, 1'b0};
                nbits <= 4'd10;
                cnt   <= {W{1'b0}};
            end
        end else if (cnt == LAST[W-1:0]) begin
            cnt   <= {W{1'b0}};
            shreg <= {1'b1, shreg[9:1]};          // 1 ビット右へ。空いた上に 1
            nbits <= nbits - 4'd1;
        end else
            cnt <= cnt + 1'b1;
endmodule
