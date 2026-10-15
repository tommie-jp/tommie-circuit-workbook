// tb_cpu8i.v  cpu8i (割り込み付き) の試験台 (11-10)。アセンブラ (11-6) の .hex を +rom= で読ませる
//   +test=main    周期 7〜60 クロックのタイマ割り込みで main.s を回す。OUT が 3 回とも 55、
//                 ticks が受け付けた数と同じ、クロック数が「割り込み無し + 22 × 受け付けた数」 (入る 1 + JMP isr 3 + 処理 18)
//   +test=nosave  同じ周期で nosave.s を回し、和が狂う周期の数を数える (1 つ以上あるはず)
//   +test=wait    周期 50 で wait.s を回し、OUT が 1 2 3 4 5 と出る
//   +test=masked  irq を 1 のままにして 11-11 のプログラムを回す (EI が無いので受け付けない)
//                 +want=<OUT の値> で最後の OUT を確かめる
//   +vcd          main の周期 40 の回の波形を cpu8i.vcd に残す
`timescale 1us/1ns
module tb_cpu8i;
    reg        clk = 0;
    reg        rst = 1;
    reg  [7:0] in_port = 8'h5A;
    reg        irq = 0;
    wire [7:0] out_port, pc;
    wire       out_stb, halted, iack, ie;
    wire [1:0] state;
    cpu8i_sys #(.ROMFILE("none.hex")) dut (.clk(clk), .rst(rst), .in_port(in_port),
        .out_port(out_port), .out_stb(out_stb), .halted(halted), .pc_out(pc), .state_out(state),
        .irq(irq), .iack(iack), .ie_out(ie));

    always #5 clk = ~clk;

    // タイマ: period クロックごとに要求を出し、受け付けられたら (iack) 下げる。period = 0 で止める
    // 要求が残っているうちに次の時刻が来たら、その分は落ちる (lost に数える)
    integer period = 0, tcount = 0, nack = 0, nlost = 0, lat = 0;
    integer lat_min = 999, lat_max = 0;
    reg     lat_on = 0;                         // 1 の間だけ、要求から受け付けまでのクロック数を集める
    reg     hold_irq = 0;                       // 1 なら irq を 1 のままにする (masked)
    always @(posedge clk) begin
        if (rst) begin
            irq <= hold_irq; tcount <= 0; nack <= 0; nlost <= 0; lat <= 0;
        end else begin
            if (iack) begin
                nack <= nack + 1;
                // lat は要求の立ち上がりから数えた立ち上がりの数。受け付けまでのクロック数は lat - 1
                if (lat_on && lat - 1 < lat_min) lat_min = lat - 1;
                if (lat_on && lat - 1 > lat_max) lat_max = lat - 1;
            end
            if (hold_irq) irq <= 1'b1;
            else if (iack) irq <= 1'b0;
            if (!hold_irq && period != 0 && tcount == period - 1) begin
                if (irq && !iack) nlost <= nlost + 1;
                else begin irq <= 1'b1; lat <= 1; end
            end else if (irq && !iack) lat <= lat + 1;
            tcount <= (period != 0 && tcount == period - 1) ? 0 : tcount + 1;
        end
    end

    reg  [7:0] outs [0:31];
    integer    nout, clocks, ng, i, p, base, bad_periods, limit;
    integer    want_out;
    reg  [8*8-1:0] test;
    always @(posedge clk) if (out_stb && nout < 32) begin outs[nout] = out_port; nout = nout + 1; end

    task load;      // プログラムを読み直す (前の回が書いたデータを消す)
        reg [8*256-1:0] fname;
        begin
            if ($value$plusargs("rom=%s", fname)) $readmemh(fname, dut.mem);
        end
    endtask

    // HLT で止まるか、max_clocks か、OUT が stop_after_outs 回出るまで走らせる (wait は HLT で止めない)
    task run(input integer max_clocks, input integer stop_after_outs);
        begin
            load;
            nout = 0;
            rst = 1;
            @(posedge clk); #1;
            rst = 0;
            clocks = 0;
            while ((!halted || test == "wait") && clocks < max_clocks && nout < stop_after_outs) begin
                @(posedge clk); #1; clocks = clocks + 1;
            end
        end
    endtask

    initial begin
        ng = 0;
        if (!$value$plusargs("test=%s", test)) test = "main";
        if (!$value$plusargs("want=%d", want_out)) want_out = -1;
        #2;
        if (test == "main") begin
            period = 0;
            run(100000, 99);
            base = clocks;
            $display("main: 割り込み無しで OUT %0d 回、HLT まで %0d クロック", nout, base);
            if (nout != 3) ng = ng + 1;
            if ($test$plusargs("vcd")) begin $dumpfile("cpu8i.vcd"); $dumpvars(0, tb_cpu8i); end
            for (p = 60; p >= 7; p = p - 1) begin
                period = p;
                lat_on = (p >= 30);                 // 処理 (22 クロック) が重ならない周期だけで測る
                if (p != 40) $dumpoff; else $dumpon;
                run(100000, 99);
                if (nout != 3 || outs[0] != 55 || outs[1] != 55 || outs[2] != 55) ng = ng + 1;
                if (dut.mem[8'hF3] != nack[7:0]) ng = ng + 1;
                if (clocks != base + 22 * nack) ng = ng + 1;
                if (nack == 0) ng = ng + 1;
                if (p == 60 || p == 40 || p == 19 || p == 7)
                    $display("  周期 %0d: OUT %0d %0d %0d、受け付け %0d 回、落とした要求 %0d、ticks %0d、%0d クロック (= %0d + 22 x %0d)",
                             p, outs[0], outs[1], outs[2], nack, nlost, dut.mem[8'hF3], clocks, base, nack);
            end
            $dumpoff;
            $display("main: 周期 7〜60 の 54 通りで、合わなかった項目 %0d", ng);
            $display("main: 周期 30〜60 で、irq が上がってから iack が上がるまで %0d〜%0d クロック", lat_min, lat_max);
        end else if (test == "nosave") begin
            bad_periods = 0;
            for (p = 60; p >= 7; p = p - 1) begin
                period = p;
                run(100000, 99);
                if (nout != 3 || outs[0] != 55 || outs[1] != 55 || outs[2] != 55)
                    bad_periods = bad_periods + 1;
            end
            $display("nosave: 周期 7〜60 の 54 通りのうち、和が狂ったのは %0d 通り", bad_periods);
            if (bad_periods == 0) ng = ng + 1;
        end else if (test == "wait") begin
            period = 50;
            run(100000, 5);
            $write("wait: OUT の並び");
            for (i = 0; i < nout; i = i + 1) $write(" %0d", outs[i]);
            $display(" (%0d 回、%0d クロック)", nout, clocks);
            for (i = 0; i < 5; i = i + 1) if (outs[i] != i + 1) ng = ng + 1;
            if (nout != 5) ng = ng + 1;
        end else if (test == "masked") begin
            hold_irq = 1;
            run(100000, 99);
            $display("masked: irq = 1 のまま、受け付け %0d 回、最後の OUT = %0d、HLT まで %0d クロック",
                     nack, out_port, clocks);
            if (nack != 0 || !halted) ng = ng + 1;
            if (want_out >= 0 && out_port != want_out[7:0]) ng = ng + 1;
        end else begin
            $display("知らない +test です");
            ng = ng + 1;
        end
        if (ng == 0) $display("PASS");
        else         $display("FAIL: %0d 件", ng);
        $finish;
    end
endmodule
