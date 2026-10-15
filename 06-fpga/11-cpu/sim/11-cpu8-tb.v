// tb_cpu8.v  cpu8 の試験台 (11-11)。アセンブラ (11-6) で作った .hex を +rom= で読ませる
//   +test=sum  n = 0〜22 で 1+…+n          (0xF1 番地に n を置く)
//   +test=mul  a × b < 256 の全部の組       (0xF0 に a、0xF1 に b を置く)
//   +test=fib  OUT の並びが 1 1 2 3 5 … 233
//   +test=ops  OUT の並びが 5A 0A FA 05 00 FE FF 42 (IN = 0x5A)
//   +vcd       最初の 1 回 (sum なら n = 10、mul なら 13 × 11) の波形を cpu8.vcd に残す
`timescale 1us/1ns
module tb_cpu8;
    reg        clk = 0;
    reg        rst = 1;
    reg  [7:0] in_port = 8'h00;
    wire [7:0] out_port, pc;
    wire       out_stb, halted;
    wire [1:0] state;
    cpu8_sys #(.ROMFILE("none.hex")) dut (.clk(clk), .rst(rst), .in_port(in_port),
        .out_port(out_port), .out_stb(out_stb), .halted(halted), .pc_out(pc), .state_out(state));

    always #5 clk = ~clk;

    reg  [8*8-1:0] test;
    reg  [7:0]     outs [0:31];
    integer        nout, clocks, ng, i, a, b, n, pairs;
    reg  [7:0]     want [0:15];

    always @(posedge clk) if (out_stb && nout < 32) begin outs[nout] = out_port; nout = nout + 1; end

    // リセットして、止まる (HLT) まで走らせる。clocks に取り出しから止まるまでのクロック数
    task run;
        begin
            nout = 0;
            rst = 1;
            @(posedge clk); #1;
            rst = 0;
            clocks = 0;
            while (!halted && clocks < 100000) begin @(posedge clk); #1; clocks = clocks + 1; end
        end
    endtask

    initial begin
        ng = 0;
        if (!$value$plusargs("test=%s", test)) test = "sum";
        #2;
        if ($test$plusargs("vcd")) begin
            $dumpfile("cpu8.vcd");
            $dumpvars(0, tb_cpu8);
        end

        if (test == "sum") begin
            run;                                        // 置いたままの n = 10
            $dumpoff;
            $display("sum: n = 10 で OUT = %0d、HLT まで %0d クロック", out_port, clocks);
            if (out_port != 8'd55) ng = ng + 1;
            for (n = 0; n <= 22; n = n + 1) begin
                dut.mem[8'hF0] = 8'd0;
                dut.mem[8'hF1] = n[7:0];
                run;
                if (nout != 1 || outs[0] != (n * (n + 1) / 2)) begin
                    $display("  n = %0d: OUT = %0d (期待 %0d)", n, outs[0], n * (n + 1) / 2);
                    ng = ng + 1;
                end
            end
            $display("sum: n = 0〜22 の 23 通りで、違ったのは %0d 通り", ng);
        end else if (test == "mul") begin
            run;                                        // 置いたままの 13 × 11
            $dumpoff;
            $display("mul: 13 x 11 で OUT = %0d、HLT まで %0d クロック", out_port, clocks);
            if (out_port != 8'd143) ng = ng + 1;
            pairs = 0;
            for (a = 0; a < 256; a = a + 1)
                for (b = 0; b < 256; b = b + 1)
                    if (a * b < 256) begin
                        dut.mem[8'hF0] = a[7:0];
                        dut.mem[8'hF1] = b[7:0];
                        dut.mem[8'hF2] = 8'd0;
                        run;
                        pairs = pairs + 1;
                        if (nout != 1 || outs[0] != a * b) ng = ng + 1;
                    end
            $display("mul: a x b < 256 の %0d 組で、違ったのは %0d 組", pairs, ng);
        end else if (test == "fib") begin
            run;
            $dumpoff;
            want[0] = 1;  want[1] = 1;  want[2] = 2;   want[3] = 3;   want[4] = 5;
            want[5] = 8;  want[6] = 13; want[7] = 21;  want[8] = 34;  want[9] = 55;
            want[10] = 89; want[11] = 144; want[12] = 233;
            if (nout != 13) ng = ng + 1;
            for (i = 0; i < 13; i = i + 1) if (outs[i] != want[i]) ng = ng + 1;
            $write("fib: OUT の並び");
            for (i = 0; i < nout; i = i + 1) $write(" %0d", outs[i]);
            $display(" (%0d 個)、HLT まで %0d クロック", nout, clocks);
        end else if (test == "ops") begin
            in_port = 8'h5A;
            run;
            $dumpoff;
            want[0] = 8'h5A; want[1] = 8'h0A; want[2] = 8'hFA; want[3] = 8'h05;
            want[4] = 8'h00; want[5] = 8'hFE; want[6] = 8'hFF; want[7] = 8'h42;
            if (nout != 8) ng = ng + 1;
            for (i = 0; i < 8; i = i + 1) if (outs[i] != want[i]) ng = ng + 1;
            $write("ops: OUT の並び");
            for (i = 0; i < nout; i = i + 1) $write(" %h", outs[i]);
            $display(" (%0d 個)", nout);
        end else begin
            $display("知らない +test です");
            ng = ng + 1;
        end
        if (ng == 0) $display("PASS");
        else         $display("FAIL: %0d 件", ng);
        $finish;
    end
endmodule
