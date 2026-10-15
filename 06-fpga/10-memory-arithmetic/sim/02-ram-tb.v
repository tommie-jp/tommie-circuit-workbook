// tb_ram.v  書く → 読む → 同じ番地を書きながら読む → 読み直す
module tb_ram;
    reg        clk = 0;
    reg        we = 0;
    reg  [3:0] addr = 0;
    reg  [7:0] wdata = 0;
    wire [7:0] rdata;
    integer    ng = 0;

    ram16x8 u (.clk(clk), .we(we), .addr(addr), .wdata(wdata), .rdata(rdata));

    always #5 clk = ~clk;        // 立ち上がりは 5, 15, 25, ... us

    // 入力は立ち上がりの 1 us 後に変え、次の立ち上がりを 1 回待つ
    task step(input w, input [3:0] a, input [7:0] d);
        begin
            we = w; addr = a; wdata = d;
            @(posedge clk); #1;
        end
    endtask

    task expect_rdata(input [7:0] e);
        begin
            if (rdata !== e) begin
                ng = ng + 1;
                $display("NG: rdata=%h (期待 %h)", rdata, e);
            end
        end
    endtask

    initial begin
        $dumpfile("ram.vcd");
        $dumpvars(0, tb_ram);
        @(posedge clk); #1;          // 6 us
        step(1, 4'h3, 8'hA5);        // 番地 3 に A5 を書く
        step(1, 4'h7, 8'h3C);        // 番地 7 に 3C を書く
        step(0, 4'h3, 8'h00);        // 番地 3 を読む (立ち上がりで rdata に入る)
        expect_rdata(8'hA5);
        step(0, 4'h7, 8'h00);        // 番地 7 を読む
        expect_rdata(8'h3C);
        step(1, 4'h3, 8'h5A);        // 番地 3 を 5A に書き換えながら、同じ番地を読む
        expect_rdata(8'hA5);         // 読めたのは書く前の語
        step(0, 4'h3, 8'h00);        // もう一度読む
        expect_rdata(8'h5A);
        step(0, 4'h7, 8'h00);        // 書いていない番地 7 は、まだ 3C
        expect_rdata(8'h3C);
        if (ng == 0) $display("PASS");
        else         $display("FAIL: %0d 件", ng);
        $finish;
    end
endmodule
