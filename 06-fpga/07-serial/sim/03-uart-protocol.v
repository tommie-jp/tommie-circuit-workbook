// 0.5 s ごとに "CNT=n\r\n" を送る。n は 0〜9 を繰り返す 1 桁。Pico 2 に載せる最上位
module count_top #(
    parameter CLK_HZ = 76_923,
    parameter BAUD   = 4800
) (
    input  clk,
    input  rst,
    output txd       // GP15
);
    localparam integer HALF = CLK_HZ / 2;                 // 0.5 s のクロック数
    localparam integer W    = $clog2(HALF);
    localparam [2:0]   LEN  = 3'd7;                        // 1 行の字数

    reg [W-1:0] tcnt;
    reg [2:0]   idx;      // 次に送る字の番号。LEN で送り終わり
    reg [3:0]   n;        // 送る数 (0〜9)
    reg         start;
    reg [7:0]   data;
    wire        busy;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(data), .start(start), .txd(txd), .busy(busy));

    // i 番目の字。数字は '0' (0x30) に n を足して作る
    function [7:0] msg(input [2:0] i, input [3:0] v);
        case (i)
            3'd0:    msg = "C";
            3'd1:    msg = "N";
            3'd2:    msg = "T";
            3'd3:    msg = "=";
            3'd4:    msg = 8'h30 + {4'd0, v};
            3'd5:    msg = 8'h0D;    // \r
            default: msg = 8'h0A;    // \n
        endcase
    endfunction

    always @(posedge clk)
        if (rst) begin
            tcnt  <= {W{1'b0}};
            idx   <= LEN;            // 送らない
            n     <= 4'd0;
            start <= 1'b0;
            data  <= 8'h00;
        end else begin
            start <= 1'b0;
            if (tcnt == HALF[W-1:0] - 1'b1) begin
                tcnt <= {W{1'b0}};
                idx  <= 3'd0;        // 0.5 s ごとに 1 行を送り始める
            end else
                tcnt <= tcnt + 1'b1;

            if (idx != LEN && !busy && !start) begin
                data  <= msg(idx, n);
                start <= 1'b1;
                idx   <= idx + 3'd1;
                if (idx == LEN - 3'd1)            // 行の最後の字を渡したら次の数へ
                    n <= (n == 4'd9) ? 4'd0 : n + 4'd1;
            end
        end
endmodule
