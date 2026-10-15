// 0.5 s ごとに "Hi\r\n" の 4 文字を送る。Pico 2 に載せる最上位
module hello_top #(
    parameter CLK_HZ = 76_923,
    parameter BAUD   = 4800
) (
    input  clk,
    input  rst,
    output txd       // GP15
);
    localparam integer HALF = CLK_HZ / 2;                 // 0.5 s のクロック数
    localparam integer W    = $clog2(HALF);

    reg [W-1:0] tcnt;    // 0.5 s を数える
    reg [2:0]   idx;     // 次に送る文字の番号。4 で送り終わり
    reg         start;
    reg [7:0]   data;
    wire        busy;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(data), .start(start), .txd(txd), .busy(busy));

    function [7:0] msg(input [2:0] i);
        case (i)
            3'd0:    msg = "H";
            3'd1:    msg = "i";
            3'd2:    msg = 8'h0D;    // \r
            default: msg = 8'h0A;    // \n
        endcase
    endfunction

    always @(posedge clk)
        if (rst) begin
            tcnt  <= {W{1'b0}};
            idx   <= 3'd4;           // 送らない
            start <= 1'b0;
            data  <= 8'h00;
        end else begin
            start <= 1'b0;
            if (tcnt == HALF[W-1:0] - 1'b1) begin
                tcnt <= {W{1'b0}};
                idx  <= 3'd0;        // 0.5 s ごとに 1 行を送り始める
            end else
                tcnt <= tcnt + 1'b1;

            if (idx != 3'd4 && !busy && !start) begin
                data  <= msg(idx);
                start <= 1'b1;       // 次のクロックで uart_tx が取り込む
                idx   <= idx + 3'd1;
            end
        end
endmodule
