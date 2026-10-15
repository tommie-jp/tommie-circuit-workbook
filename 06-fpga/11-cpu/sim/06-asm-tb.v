// tb_asm.v  アセンブラの出力 (.hex) を td4x_rom (11-5) に読ませて走らせる (11-6)
//   +rom=<.hex>  読ませるファイル        +in=<0〜15>     入力ポート
//   +cycles=<N>  走らせるクロック数      +expect=<0〜15> 最後の OUT
//   +seq=<16 進の字の並び>  1 クロックごとの OUT の並び (先頭から。書けば突き合わせる)
//   +vcd         波形を asm.vcd に残す
`timescale 1us/1ns
module tb_asm;
    reg        clock = 0;
    reg        reset_n = 1;
    reg  [3:0] in_port = 0;
    wire [3:0] pc, out_port;
    wire [7:0] op;
    wire       fc, fz;
    td4x_rom #(.ROMFILE("none.hex")) dut (.clock(clock), .reset_n(reset_n), .in_port(in_port),
        .pc_out(pc), .op(op), .out_port(out_port), .flag_c(fc), .flag_z(fz));

    integer        cycles, expect_out, in_val, i, nseq, ng;
    reg [8*64-1:0] seq;
    reg [7:0]      ch;
    reg [3:0]      want;

    initial begin
        ng = 0;
        if (!$value$plusargs("cycles=%d", cycles)) cycles = 32;
        if (!$value$plusargs("in=%d", in_val)) in_val = 0;
        if (!$value$plusargs("expect=%d", expect_out)) expect_out = -1;
        seq = 0;
        nseq = 0;
        if ($value$plusargs("seq=%s", seq))
            for (i = 0; i < 64; i = i + 1) if (seq[8*i +: 8] != 8'd0) nseq = i + 1;
        in_port = in_val[3:0];
        if ($test$plusargs("vcd")) begin
            $dumpfile("asm.vcd");
            $dumpvars(0, tb_asm);
        end
        #1 reset_n = 0;
        #4 reset_n = 1;
        #5;
        for (i = 0; i < cycles; i = i + 1) begin
            clock = 1; #5; clock = 0; #5;
            if (i < nseq) begin
                ch = seq[8*(nseq-1-i) +: 8];             // 左の字が 1 クロック目
                want = (ch >= "a") ? ch - "a" + 10 : (ch >= "A") ? ch - "A" + 10 : ch - "0";
                if (out_port !== want) begin
                    $display("  %0d クロック目の OUT = %h (期待 %h)", i + 1, out_port, want);
                    ng = ng + 1;
                end
            end
        end
        if (expect_out >= 0 && out_port !== expect_out[3:0]) ng = ng + 1;
        $display("%0d クロック後: PC = %0d、OUT = %0d%s", cycles, pc, out_port,
                 (ng == 0) ? "  PASS" : "  FAIL");
        $finish;
    end
endmodule
