// 既定の CLK_HZ (27 000 000) で、秒の tick と桁の切り替えが何クロックごとかを数える
module tb_clock27m;
    reg clk = 0;
    reg rst = 1;
    wire [7:0]  seg;
    wire [3:0]  dig;
    wire        sec;
    wire [23:0] now;
    integer cycles = 0, last_sec = 0, last_dig = 0, n_dig = 0;
    reg [3:0] prev_dig = 4'b1000;

    clock u (.clk(clk), .rst(rst), .btn_hour_n(1'b1), .btn_min_n(1'b1), .sync_n(1'b1),
             .seg(seg), .dig(dig), .sec(sec), .now(now));

    always #1 clk = ~clk;

    always @(posedge clk) if (!rst) begin
        cycles <= cycles + 1;
        if (u.en_sec) begin
            $display("sec tick at clock %0d (%0d clocks after the previous one) now=%h", cycles, cycles - last_sec, now);
            last_sec <= cycles;
        end
        if (dig !== prev_dig) begin
            if (n_dig < 5) $display("dig %b -> %b at clock %0d (%0d clocks)", prev_dig, dig, cycles, cycles - last_dig);
            n_dig <= n_dig + 1;
            last_dig <= cycles;
            prev_dig <= dig;
        end
    end

    initial begin
        #6 rst = 0;
        #(2 * 82_000_000) $finish;
    end
endmodule
