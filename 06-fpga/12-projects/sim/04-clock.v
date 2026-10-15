module clock #(
    parameter CLK_HZ  = 27_000_000,
    parameter SCAN_HZ = 1_000,       // 桁を切り替える速さ。4 桁なので 1 桁は 250 Hz で光る
    parameter BTN_HZ  = 100          // ボタンを見る速さ (10 ms ごと)
) (
    input        clk,
    input        rst,
    input        btn_hour_n,         // 押すと 0。時を 1 進める
    input        btn_min_n,          // 押すと 0。分を 1 進め、秒を 0 にする
    input        sync_n,             // 押すと 0。正時に合わせる (時報の正時パルス)
    output [7:0] seg,                // {dp, g, f, e, d, c, b, a}。1 で点灯
    output [3:0] dig,                // 1 の桁だけ光る。dig[3] が左端 (時の 10 の位)
    output       sec,                // 秒の前半 0.5 s だけ 1
    output [23:0] now                // 時分秒の 6 桁 {h10, h1, m10, m1, s10, s1}。試験で見る
);
    wire en_half, en_scan, en_btn;

    tick #(.CLK_HZ(CLK_HZ), .TICK_HZ(2))       t_half (.clk(clk), .rst(rst), .en(en_half));
    tick #(.CLK_HZ(CLK_HZ), .TICK_HZ(SCAN_HZ)) t_scan (.clk(clk), .rst(rst), .en(en_scan));
    tick #(.CLK_HZ(CLK_HZ), .TICK_HZ(BTN_HZ))  t_btn  (.clk(clk), .rst(rst), .en(en_btn));

    wire p_hour, p_min, p_sync;

    button b_hour (.clk(clk), .rst(rst), .sample(en_btn), .btn_n(btn_hour_n), .press(p_hour));
    button b_min  (.clk(clk), .rst(rst), .sample(en_btn), .btn_n(btn_min_n),  .press(p_min));
    button b_sync (.clk(clk), .rst(rst), .sample(en_btn), .btn_n(sync_n),     .press(p_sync));

    // 時分秒を 10 進の 6 桁で持つ
    wire [3:0] s1, s10, m1, m10, h1, h10;
    wire c_s1, c_s10, c_m1, c_m10, c_h1;

    // 正時に合わせる: 30 分より前なら今の時の 00 分、30 分からは次の時の 00 分
    wire round_up = p_sync && (m10 >= 4'd3);
    wire clr_ms   = p_min || p_sync;
    wire inc_min  = !p_sync && ((c_s10 && !p_min) || p_min);
    wire inc_hour = (c_m10 && !p_sync) || p_hour || round_up;

    // 0.5 s ごとの tick を 2 回に 1 回だけ通して 1 秒にする。half が 1 の間が秒の前半
    reg half;
    always @(posedge clk)
        if (rst)          half <= 1'b0;
        else if (en_half) half <= ~half;
    wire en_sec = en_half && !half;
    assign sec  = half;

    // 時は 00〜23。時の 1 の位は、10 の位が 2 のときだけ 3 で折り返す
    wire [3:0] h1_last = (h10 == 4'd2) ? 4'd3 : 4'd9;

    digit d_s1  (.clk(clk), .rst(rst), .clr(clr_ms), .inc(en_sec),   .last(4'd9),    .q(s1),  .carry(c_s1));
    digit d_s10 (.clk(clk), .rst(rst), .clr(clr_ms), .inc(c_s1),     .last(4'd5),    .q(s10), .carry(c_s10));
    digit d_m1  (.clk(clk), .rst(rst), .clr(p_sync), .inc(inc_min),  .last(4'd9),    .q(m1),  .carry(c_m1));
    digit d_m10 (.clk(clk), .rst(rst), .clr(p_sync), .inc(c_m1),     .last(4'd5),    .q(m10), .carry(c_m10));
    digit d_h1  (.clk(clk), .rst(rst), .clr(1'b0),   .inc(inc_hour), .last(h1_last), .q(h1),  .carry(c_h1));
    /* verilator lint_off PINCONNECTEMPTY */    // 23 時の次は 0 時。時の 10 の位の carry は使わない
    digit d_h10 (.clk(clk), .rst(rst), .clr(1'b0),   .inc(c_h1),     .last(4'd2),    .q(h10), .carry());
    /* verilator lint_on PINCONNECTEMPTY */

    // ダイナミック点灯 (2-15): 1 ms ごとに光らせる桁を 1 つずらす
    reg [1:0] pos;
    always @(posedge clk)
        if (rst)          pos <= 2'd0;
        else if (en_scan) pos <= pos + 2'd1;

    reg [3:0] shown;
    always @(*)
        case (pos)
            2'd0:    shown = h10;
            2'd1:    shown = h1;
            2'd2:    shown = m10;
            default: shown = m1;
        endcase

    wire [6:0] abc;
    seg7dec dec (.n(shown), .seg(abc));

    assign seg = {sec && (pos == 2'd1), abc};    // 時の 1 の位の点を秒に合わせて点滅
    assign dig = 4'b1000 >> pos;
    assign now = {h10, h1, m10, m1, s10, s1};
endmodule
