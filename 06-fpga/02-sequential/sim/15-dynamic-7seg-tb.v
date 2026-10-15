// CLK_HZ = 1000 (1 クロック = 1 ms) で、消さない版 (u) と消す版 (b) を並べて回す
module tb_dyn7seg;
    reg clk = 0;
    reg rst = 1;
    wire [7:0]  seg,   seg_b;
    wire [3:0]  dig,   dig_b;
    wire [15:0] value, value_b;
    integer errors = 0;

    dyn7seg #(.CLK_HZ(1000), .BLANK(0)) u (.clk(clk), .rst(rst), .seg(seg),   .dig(dig),   .value(value));
    dyn7seg #(.CLK_HZ(1000), .BLANK(1)) b (.clk(clk), .rst(rst), .seg(seg_b), .dig(dig_b), .value(value_b));

    always #1 clk = ~clk;                    // 1 周期 = 2 時間単位 = 1 ms とみなす

    task ms(input integer n);
        repeat (n) @(posedge clk);
    endtask

    task check(input ok, input [8*28-1:0] what);
        if (!ok) begin
            $display("NG %0s", what);
            errors = errors + 1;
        end else
            $display("ok %0s", what);
    endtask

    // 0〜9 の a〜g (2-9 の seg7 と同じ表)
    function [7:0] pat(input [3:0] n);
        case (n)
            4'd0: pat = 8'h3f;  4'd1: pat = 8'h06;  4'd2: pat = 8'h5b;  4'd3: pat = 8'h4f;
            4'd4: pat = 8'h66;  4'd5: pat = 8'h6d;  4'd6: pat = 8'h7d;  4'd7: pat = 8'h07;
            4'd8: pat = 8'h7f;  4'd9: pat = 8'h6f;  default: pat = 8'h00;
        endcase
    endfunction

    // 今 dig で光っている桁の数の模様が seg に出ているか
    function shows_right(input [3:0] dg, input [7:0] sg, input [15:0] v);
        case (dg)
            4'b1000: shows_right = (sg == pat(v[15:12]));
            4'b0100: shows_right = (sg == pat(v[11:8]));
            4'b0010: shows_right = (sg == pat(v[7:4]));
            4'b0001: shows_right = (sg == pat(v[3:0]));
            4'b0000: shows_right = (sg == 8'h00);       // 消している間は seg も 0
            default: shows_right = 1'b0;                // 2 桁が同時に光ってはいけない
        endcase
    endfunction

    // 走らせている間、毎クロックの終わりに確かめる
    integer bad = 0, bad_b = 0;
    always @(negedge clk) if (!rst) begin
        if (!shows_right(dig,   seg,   value))   bad   = bad + 1;
        if (!shows_right(dig_b, seg_b, value_b)) bad_b = bad_b + 1;
    end

    // n クロックのうち、各桁が光ったクロックの数
    integer on1, on2, on3, on4, on1b, on2b, on3b, on4b, k;
    task count_on(input integer n);
        begin
            on1 = 0; on2 = 0; on3 = 0; on4 = 0; on1b = 0; on2b = 0; on3b = 0; on4b = 0;
            for (k = 0; k < n; k = k + 1) begin
                @(negedge clk);
                if (dig[3])   on1  = on1  + 1;
                if (dig[2])   on2  = on2  + 1;
                if (dig[1])   on3  = on3  + 1;
                if (dig[0])   on4  = on4  + 1;
                if (dig_b[3]) on1b = on1b + 1;
                if (dig_b[2]) on2b = on2b + 1;
                if (dig_b[1]) on3b = on3b + 1;
                if (dig_b[0]) on4b = on4b + 1;
            end
        end
    endtask

    reg [3:0] d_seq [0:7];
    reg [3:0] b_seq [0:7];
    integer i;
    initial begin
        ms(3); @(negedge clk); rst = 0;   // クロックの立ち下がりで放す

        // 放した所から 8 クロックの桁の並び
        for (i = 0; i < 8; i = i + 1) begin
            d_seq[i] = dig; b_seq[i] = dig_b;
            @(negedge clk);
        end
        $display("dig   : %b %b %b %b %b %b %b %b", d_seq[0], d_seq[1], d_seq[2], d_seq[3], d_seq[4], d_seq[5], d_seq[6], d_seq[7]);
        $display("dig_b : %b %b %b %b %b %b %b %b", b_seq[0], b_seq[1], b_seq[2], b_seq[3], b_seq[4], b_seq[5], b_seq[6], b_seq[7]);
        check(d_seq[0] == 4'b1000 && d_seq[1] == 4'b0100 && d_seq[2] == 4'b0010 && d_seq[3] == 4'b0001
              && d_seq[4] == 4'b1000, "1 clock per digit");
        check(b_seq[0] == 4'b1000 && b_seq[1] == 4'b0000 && b_seq[2] == 4'b0100 && b_seq[3] == 4'b0000
              && b_seq[4] == 4'b0010 && b_seq[6] == 4'b0001, "blank between digits");

        // 4000 クロック (4 s) で、各桁が光ったクロックの数
        count_on(4000);
        $display("on (BLANK=0): %0d %0d %0d %0d of 4000", on1, on2, on3, on4);
        $display("on (BLANK=1): %0d %0d %0d %0d of 4000", on1b, on2b, on3b, on4b);
        check(on1 == 1000 && on2 == 1000 && on3 == 1000 && on4 == 1000, "duty 1/4");
        check(on1b == 500 && on2b == 500 && on3b == 500 && on4b == 500, "duty 1/8 with blank");

        // 数える値: リセットを放してから 1 s ごとに 1
        // 放してから 8 + 4000 = 4008 ms。215.5 s まで進めて 0215
        ms(215_500 - 4008);
        $display("value at 215.5 s: %h / %h", value, value_b);
        check(value == 16'h0215 && value_b == 16'h0215, "count 0215");

        ms(1000 * 9784);                 // 9999.5 s
        $display("value at 9999.5 s: %h", value);
        check(value == 16'h9999, "count 9999");
        ms(1000);                        // 10000.5 s
        $display("value at 10000.5 s: %h", value);
        check(value == 16'h0000, "wrap to 0000");

        $display("wrong pattern clocks: %0d / %0d", bad, bad_b);
        check(bad == 0 && bad_b == 0, "seg matches dig");

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d", errors);
        $finish;
    end
endmodule
