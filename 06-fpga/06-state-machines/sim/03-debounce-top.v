// 押すたびに LED を点けたり消したりする。D1 は生の入力で、D2 はチャタリングを取ってから
module debounce_top #(
    parameter CLK_HZ = 1000
) (
    input      clk,
    input      rst,
    input      btn_n,       // GP0。押すと 0
    output reg led_raw,     // GP15 (D1)。生の入力の立ち下がりごとに反転
    output reg led_clean,   // GP14 (D2)。press ごとに反転
    output     led_hold     // GP16 (D3)。チャタリングを取った値で、押している間 1
);
    wire clean_n;
    wire press;

    debounce #(.N(CLK_HZ / 50)) u_db (      // 1/50 s = 20 ms
        .clk(clk), .rst(rst), .btn_n(btn_n), .clean_n(clean_n), .press(press));

    // 生の入力も 2 段で受けてから立ち下がりを見る (段の数を D2 とそろえる)
    reg [2:0] raw;
    always @(posedge clk)
        if (rst) raw <= 3'b111;
        else     raw <= {raw[1:0], btn_n};
    wire raw_fall = raw[2] & ~raw[1];

    always @(posedge clk)
        if (rst) begin
            led_raw   <= 1'b0;
            led_clean <= 1'b0;
        end else begin
            if (raw_fall) led_raw   <= ~led_raw;
            if (press)    led_clean <= ~led_clean;
        end

    assign led_hold = ~clean_n;
endmodule
