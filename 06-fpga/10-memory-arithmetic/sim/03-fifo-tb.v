// tb_fifo.v  入れる → いっぱいで入れる → 出す → 入れながら出す → 空まで出す → 空で出す
module tb_fifo;
    reg        clk = 0;
    reg        rst = 1;
    reg        push = 0;
    reg  [3:0] din = 0;
    reg        pop = 0;
    wire [3:0] dout;
    wire       full, empty;
    wire [2:0] count;
    integer    ng = 0;
    integer    n_pop = 0;
    reg  [3:0] exp [0:7];        // 出てくるはずの語を、出る順に並べた表

    fifo4x4 u (.clk(clk), .rst(rst), .push(push), .din(din), .pop(pop),
               .dout(dout), .full(full), .empty(empty), .count(count));

    always #5 clk = ~clk;        // 立ち上がりは 5, 15, 25, ... us

    // 実際に捨てられる語 (pop が 1 で empty でない立ち上がり) を、表と比べる
    always @(posedge clk)
        if (!rst && pop && !empty) begin
            if (dout !== exp[n_pop]) begin
                ng = ng + 1;
                $display("NG: %0d 語目 dout=%h (期待 %h)", n_pop, dout, exp[n_pop]);
            end
            n_pop = n_pop + 1;
        end

    // 入力は立ち上がりの 1 us 後に変え、次の立ち上がりを 1 回待つ
    task step(input p, input [3:0] d, input q);
        begin
            push = p; din = d; pop = q;
            @(posedge clk); #1;
        end
    endtask

    initial begin
        exp[0] = 4'hA; exp[1] = 4'hB; exp[2] = 4'hC; exp[3] = 4'hD; exp[4] = 4'h6;
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_fifo);
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;                     // 16 us: リセットを放す
        step(1, 4'hA, 0);            // A を入れる
        step(1, 4'hB, 0);
        step(1, 4'hC, 0);
        step(1, 4'hD, 0);            // 4 語入って full
        step(1, 4'hE, 0);            // full で入れようとする: E は捨てられる
        step(0, 4'h0, 1);            // A を出す
        step(0, 4'h0, 1);            // B を出す
        step(1, 4'h6, 1);            // 6 を入れながら C を出す
        step(0, 4'h0, 1);            // D を出す
        step(0, 4'h0, 1);            // 6 を出す。empty になる
        step(0, 4'h0, 1);            // empty で出そうとする: 何も起きない
        step(0, 4'h0, 0);
        if (ng == 0 && n_pop == 5) $display("PASS: 5 語が入れた順に出た");
        else                       $display("FAIL: 違い %0d 件、出た語 %0d", ng, n_pop);
        $finish;
    end
endmodule
